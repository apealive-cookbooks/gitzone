
default['gitzone']['preffix'] = "/usr"
default['gitzone']['group'] = "gitzone"
default['gitzone']['home'] = "/home"
default['gitzone']['repo_dir'] = "/srv/repos/git"
default['gitzone']['repo_url'] = "https://github.com/dyne/gitzone.git"
default['gitzone']['bind_repos_dir'] = "/etc/bind/repos"


#TODO MAKE IT HASH too loop over user that may modify
#TODO "loop over if multiple keys"
#if user pub key is nil? Then generate pub/private keys.
default['gitzone']['user_ssh_pub_keys'] = nil

#TODO loop over users, domains managed from data bag
#   iterate over to create per $user zone.cfg for domains defined in data bag
default['gitzone']['user'] = ""
default['gitzone']['domains'] = %w{ }


#TODO Wrap all BIND cookbook attributes used in recipe to GITZONE attributes
default['gitzone']['bind_cache_dir'] = '/var/cache/bind'

#Bad practice (unimportant dependencies)
#default['gitzone']['zone_cfg'] = "#{node['gitzone']['bind_repos_dir']}/#{node['gitzone']['user']}.conf"
#default['gitzone']['zone_dir'] = "#{node[:gitzone][:home]}/zones/#{node[:gitzone][:user]}"

