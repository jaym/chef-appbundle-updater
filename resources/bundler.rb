provides :bundler

actions :install, :exec
default_action :install

attribute :path, :name_attribute => true, :kind_of => String, :required => true
attribute :args, :kind_of => String
