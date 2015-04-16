require 'fileutils'
require 'chef/http/simple'
require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut

provides :appbundle

def whyrun_supported?
  true
end

def load_current_resource

end

action :install do
  converge_by("Install gem dependencies") do
    shell_out!("#{bundle} install", :cwd => new_resource.path)
  end
  converge_by("Run #{appbundle} #{new_resource.path} #{bin}") do
    shell_out!("#{appbundle} #{new_resource.path} #{bin}", :cwd => new_resource.path)
  end
end

private

def bundle
  ::File.join(embedded_bin, "bundle")
end

def appbundle
  ::File.join(embedded_bin, "appbundler")
end

def embedded_bin
  ::File.join(embedded, "bin")
end


def bin
  ::File.join(omnibus_root, "bin")
end

def embedded
  ::File.join(omnibus_root, "embedded")
end

def omnibus_root
  ::File.expand_path(::File.join(Gem.ruby, "..", "..", ".."))
end
