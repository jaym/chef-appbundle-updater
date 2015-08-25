provides :rake

actions :run
default_action :run

attribute :task, :name_attribute => true, :kind_of => String, :required => true
attribute :cwd , :kind_of => String, :required => true
attribute :bundle, :kind_of => [TrueClass, FalseClass], :default => true
