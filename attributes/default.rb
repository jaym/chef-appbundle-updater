default['chef_appbundle_updater']['github_org'] = 'chef'
default['chef_appbundle_updater']['github_repo'] = 'chef'

# A git sha like thing. Search order: sha, branch, tag
default['chef_appbundle_updater']['refname'] = 'master'

# The base directory where Chef will be unpacked
default['chef_appbundle_updater']['destination'] = "#{Chef::Config[:file_cache_path]}/chef"
