
zone_cfg = ::File.join(node['gitzone']['bind_repos_dir'], "#{node['gitzone']['user']}.conf")
#TODO: read from attributes
bind_named_cfg = ::File.join(node['bind']['sysconfdir'], "named.conf.local")
bind_cache_dir_gitzone = ::File.join(node['gitzone']['bind_cache_dir'], node['gitzone']['user'])


#add gitzone user to bind group || or-and create it
group node['bind']['group'] do
    members node['gitzone']['user']
    append true
    action :create
end


# create gitzone cache dir
directory bind_cache_dir_gitzone do
    #TODO: place bind cache dir as attribute (differ with distribution)
    owner node['gitzone']['user']
    group node['bind']['user']
    mode '0750'
    recursive true
end

# create bind repos dir
directory node['gitzone']['bind_repos_dir'] do
    owner node['gitzone']['user']
    group node['bind']['user']
    mode '0750'
    recursive true
end

# create gitzone zone conf
#TODO: This should do .each if array
template zone_cfg do
    source "zone.conf.erb"
    owner node['gitzone']['user']
    group node['bind']['group']
    mode '0750'
    variables({
        :domains => node['gitzone']['domains'],
        })
    action :create
    notifies :create, "ruby_block[include-zone-in-named.conf.local]", :delayed
end


# extend named conf (how only once?)
ruby_block "include-zone-in-named.conf.local" do
  only_if { ::File.exist?(bind_named_cfg)}
  Chef::Log.warn("ruby block run cfg to use: " + bind_named_cfg.to_s)
  block do
    fe = Chef::Util::FileEdit.new(bind_named_cfg)
    fe.insert_line_if_no_match(/include #{zone_cfg}/, "include #{zone_cfg}")
    fe.write_file
  end
  action :create
  #notifies :reload, "service[bind]"
end

