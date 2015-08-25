require 'fileutils'
require 'chef/http/simple'
require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut

provides :rake

def whyrun_supported?
  true
end

def load_current_resource

end

action :run do
  if new_resource.bundle
    bundler new_resource.cwd do
      action :exec
      args "rake #{new_resource.task}"
    end
  else
    converge_by("Running rake #{new_resource.task}") do
      shell_out!("#{rake} #{new_resource.task}", :cwd => new_resource.cwd)
    end
  end
end

private

def rake
  ::File.join(embedded_bin, "rake")
end

def embedded_bin
  ::File.join(embedded, "bin")
end

def embedded
  ::File.join(omnibus_root, "embedded")
end

def omnibus_root
  ::File.expand_path(::File.join(Gem.ruby, "..", "..", ".."))
end
