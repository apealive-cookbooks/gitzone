


zone_dir = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones', node['gitzone']['user'])

# create zone file (if not exist)
#TODO: generate reverse zone files
node['gitzone']['domains'].each do |domain|
    zone_file = ::File.join(zone_dir, domain)
    template "#{zone_file}" do
        not_if { File.exist?(zone_file)}
        source "zone_file.erb"
        owner node['gitzone']['user']
        group node['gitzone']['group']
        mode '0750'
        variables({
            :domain => domain,
            #TODO: databag - to load from entries from
            :host_entries => {
                node['hostname'] => node['ipaddress'],
                },
            })
        action :create
    end
end

# update zone file with host searched in the domain
#TODO: generate reverse zone files
node['gitzone']['domains'].each do |domain|
    zone_file = ::File.join(zone_dir, domain)
    ruby_block "update-zone-file" do
        block do
            #search for hosts
            #TOOD - insert server entry if not yet created
        end
        only_if { File.exist?(zone_file)}
    action  :run
    notifies :run, "bash[git_commit_zone_file]",:delayed
    end
end

bash "git_commit_zone_file" do
    #only_if { File.exist?(zone_file)}
    cwd zone_dir
    user node['gitzone']['user']
    group node['gitzone']['group']
    code <<-EOF
        git add *
        git commit -m "modified zone_file"
     EOF
    ignore_failure false
    action :nothing
end

