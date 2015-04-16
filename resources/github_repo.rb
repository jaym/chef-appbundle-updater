provides :github_repo

actions :download
default_action :download

attribute :owner, :kind_of => String, :required => true
attribute :repo, :kind_of => String, :required => true
attribute :refname, :kind_of => String, :default => 'master'
attribute :destination, :kind_of => String, :required => true
