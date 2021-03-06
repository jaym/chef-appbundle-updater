case node['platform_family']
when 'debian'
  include_recipe 'apt::default'
end

include_recipe 'build-essential::default'

github_repo 'chef/chef' do
  owner       node['chef_appbundle_updater']['github_org']
  repo        node['chef_appbundle_updater']['github_repo']
  refname     node['chef_appbundle_updater']['refname']
  destination node['chef_appbundle_updater']['destination']
end

bundler node['chef_appbundle_updater']['destination']

# This will be part of Chef 12.4
rake 'install_components' do
  cwd node['chef_appbundle_updater']['destination']

  only_if do
    ::File.exists?(::File.join(node['chef_appbundle_updater']['destination'], 'chef-config'))
  end
end

# Appbundler now needs an actual gem to be installed
# and points the stubs to it.
rake 'install' do
  cwd node['chef_appbundle_updater']['destination']
end

appbundle node['chef_appbundle_updater']['destination']
