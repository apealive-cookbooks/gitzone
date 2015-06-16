# gitzone deployment options
default['gitzone']['preffix'] = '/usr'
default['gitzone']['home'] = '/home'
default['gitzone']['repo_dir'] = '/srv/repos/git'
default['gitzone']['bind_repos_dir'] = '/etc/named/repos'
case node['platform_family']
when 'debian'
  default['gitzone']['bind_repos_dir'] = '/etc/bind/repos'    # ie: node.bind.sysconfdir
end
# gitzone source repo
default['gitzone']['repo_url'] = 'https://github.com/dyne/gitzone.git'

# system user to manage gitzone repos/files?
default['gitzone']['user'] = 'gitzone'
default['gitzone']['group'] = 'gitzone'
# system admin (must exist on system)
default['gitzone']['admin'] = nil

# ssh pub keys for authorized_keys.
default['gitzone']['user_ssh_pub_keys'] = [] # users allowed to login the gitzone user. Generate pub/private keys if []
default['gitzone']['managed_nodes_pub_keys'] = [] # auto populated (based on search query - search_query_managed_nodes)
default['gitzone']['rewrite_authorized_keys_file'] = false # whether to rewrite or append authorized_keys on each run

# managed domains
default['gitzone']['domains'] = %w(example.com example.net)

# search query gitzone node & managed nodes
default['gitzone']['search_query'] = 'recipes:gitzone\:\:default'   # used by dyndns recipe at client node
default['gitzone']['search_query_managed_nodes'] = 'chef_environment:*'   # used by gitzone node to populate managed_nodes_pub_keys

# repos to be configured in gitzone.conf $repos
default['gitzone']['conf']['repos'] = ''
