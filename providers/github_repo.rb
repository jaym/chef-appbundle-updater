require 'fileutils'
require 'chef/http/simple'
require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut

provides :github_repo

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = @new_resource.class.new(@new_resource.name).tap do |r|
    r.owner new_resource.owner
    r.repo new_resource.repo
    r.destination new_resource.destination

    ::File.join(new_resource.destination, '.gitsha').tap do |sha_path|
      if ::File.exist?(sha_path)
        r.refname ::File.read(sha_path)
      else
        r.refname nil
      end
    end
  end
end

action :download do
  sha = refname_to_sha

  if current_resource.refname != sha
    git_url = "https://github.com/#{owner}/#{repo}/archive/#{sha}.tar.gz"

    cache_file_path = ::File.join(
      Chef::Config[:file_cache_path],
      ::File.basename(git_url)
    )

    converge_by('Downloading repo at ') do
      Chef::Resource::RemoteFile.new(cache_file_path, run_context).tap do |r|
        r.source git_url
        r.backup false
        r.run_action :create
      end
    end

    destination_path = ::File.join(
      Chef::Config[:file_cache_path],
      ::File.basename(git_url, '.tar.gz')
    )

    Chef::Resource::Directory.new(destination_path, run_context).tap do |r|
      r.run_action :delete
    end

    converge_by("Unpacking repo to #{new_resource.destination}") do
      base_dirname = ::File::dirname(destination_path)
      repo_dirname = ::File.join(base_dirname, "#{repo}-#{sha}")

      shell_out!("tar -xzf #{cache_file_path} -C #{base_dirname}")

      Chef::Resource::File.new(::File.join(repo_dirname, '.gitsha'), run_context).tap do |r|
        r.content sha
        r.run_action :create
      end

      Chef::Resource::Directory.new(new_resource.destination, run_context).tap do |r|
        r.run_action :delete
      end

      FileUtils.mv(repo_dirname, new_resource.destination)
    end
  end
end

private

def is_sha1?
  (new_resource.refname =~ /\b([a-f0-9]{40})\b/) != nil
end

def refname_to_sha
  sha ||= begin
    s = if is_sha1?
          new_resource.refname
        else
          check_refs
        end

    if s.nil? || s.length == 0
      raise "could not find #{new_resource.refname} in https://github.com/#{owner}/#{repo}"
    else
      s
    end
  end
end

def check_refs
  refspecs.each do |x|
    begin
      Chef::Log.info("Trying #{x}")
      response = api_http_connection.get("/repos/#{owner}/#{repo}/git/#{x}")
      json = JSON.parse(response)
      return json['object']['sha']
    rescue Net::HTTPServerException => e
      if e.response.code == '404'
        Chef::Log.info("#{x} not found")
        nil
      else
        raise
      end
    end
  end
  []
end

def refspecs
  [:branch_ref, :tag_ref].map do |x|
    method(x).call
  end
end

def branch_ref
  "refs/heads/#{new_resource.refname}"
end

def tag_ref
  "refs/tags/#{new_resource.refname}"
end

def sha_ref
  new_resource.refname
end

def api_http_connection
  @http_conn ||= Chef::HTTP::Simple.new('https://api.github.com')
end

def owner
  new_resource.owner
end

def repo
  new_resource.repo
end
