
zone_cfg = ::File.join(node['gitzone']['bind_repos_dir'], "#{node['gitzone']['user']}.conf")
bind_named_cfg = ::File.join(node['bind']['sysconfdir'], 'named.conf')
bind_cache_dir_gitzone = ::File.join(node['bind']['vardir'], node['gitzone']['user'])

# add rndc configuration used by gitzone - creates gitzone-rndc.conf and set include from named.conf
gitzone_rndc_cfg = ::File.join(node['bind']['sysconfdir'], 'gitzone-rndc.conf')
template 'gitzone-rndc.conf' do
  path = gitzone_rndc_cfg
  action :create
  not_if { ::File.exist?(path) }
end
if ::File.exist?(gitzone_rndc_cfg)
  # once template is run
  node.set['bind']['included_files'] = (['gitzone-rndc.conf'] + node[:bind][:included_files]).uniq.sort
end

# add gitzone user to bind group || or-and create it
group node['bind']['group'] do
  members node['gitzone']['user']
  append true
  action :create
end

# create gitzone dir in bind var/cache dir
directory bind_cache_dir_gitzone do
  owner node['gitzone']['user']
  group node['bind']['group']
  mode '0770'
  recursive true
end

# create bind repos dir
directory node['gitzone']['bind_repos_dir'] do
  owner node['gitzone']['user']
  group node['bind']['group']
  mode '0750'
  recursive true
end

# create gitzone zone conf
template zone_cfg do
  source 'zone.conf.erb'
  owner node['gitzone']['user']
  group node['bind']['group']
  mode '0750'
  variables(
      domains: node['gitzone']['domains']
      )
  # only creates a new files if they do not exist yet, otherwise zone files are not modified !!
  action :create
  notifies :create, 'ruby_block[include-zone-in-named.conf]', :delayed
end

# extend named conf to load gitzone zone conf
ruby_block 'include-zone-in-named.conf' do
  only_if { ::File.exist?(bind_named_cfg) }
  Chef::Log.warn('ruby block run cfg to use: ' + bind_named_cfg.to_s)
  block do
    fe = Chef::Util::FileEdit.new(bind_named_cfg)
    fe.insert_line_if_no_match(/include \"#{zone_cfg}*/, "include \"#{zone_cfg}\";")
    fe.write_file
  end
  action :create
  # notifies :reload, "service[bind]"
end
