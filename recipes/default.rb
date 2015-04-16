case node['platform_family']
when 'debian'
  include_recipe 'apt::default'
end

include_recipe 'build-essential::default'

github_repo 'chef/chef' do
  owner   'chef'
  repo    'chef'
  refname 'master'
  destination "#{Chef::Config[:file_cache_path]}/chef"
end

appbundle "#{Chef::Config[:file_cache_path]}/chef"
