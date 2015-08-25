require 'fileutils'
require 'chef/http/simple'
require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut

provides :bundler

def whyrun_supported?
  true
end

def load_current_resource

end

action :install do
  converge_by("Install gem dependencies") do
    shell_out!("#{bundle} install #{new_resource.args}", :cwd => new_resource.path)
  end
end

action :exec do
  converge_by("Execute in the context of bundler") do
    shell_out("#{bundle} exec #{new_resource.args}", :cwd => new_resource.path)
  end
end

private

def bundle
  ::File.join(embedded_bin, "bundle")
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
