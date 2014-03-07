#gitzone deployment options
default['gitzone']['preffix'] = "/usr"
default['gitzone']['home'] = "/home"
default['gitzone']['repo_dir'] = "/srv/repos/git"
default['gitzone']['bind_repos_dir'] = "/etc/named/repos"
case node['platform_family']
    when 'debian'
    default['gitzone']['bind_repos_dir'] = "/etc/bind/repos"    #ie: node.bind.sysconfdir
end
#gitzone source repo
default['gitzone']['repo_url'] = "https://github.com/dyne/gitzone.git"


#system user to manage gitzone repos/files?
default['gitzone']['user'] = "gitzone"
default['gitzone']['group'] = "gitzone"
#system admin (must exist on system)
default['gitzone']['admin'] = nil

#gitzone user pub keys. generate pub/private keys if nil
default['gitzone']['user_ssh_pub_keys'] = nil


#managed domains
default['gitzone']['domains'] = %w{ example.com example.net }

#repos to be configured in gitzone.conf $repos
default['gitzone']['conf']['repos'] = ""


