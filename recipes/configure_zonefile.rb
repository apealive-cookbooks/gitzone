


zone_repo = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones', node['gitzone']['user'])
zone_clon = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones-wc-' + node['gitzone']['user'])

# check out the latest gitzone repo
git zone_clon do
  only_if { ::File.exist?(zone_repo) }
  repository zone_repo
  #reference "master"
  revision "HEAD"
  action :sync
  user node['gitzone']['user']
  group node['gitzone']['group']
  #ignore failures to be able clone empty repository
  ignore_failure true
  ##notifies :run, "execute[gitzone-make-install]", :immediately
end

# create zone file (if not exist)
#TODO: generate reverse zone files
node['gitzone']['domains'].each do |dom|
    zone_file = ::File.join(zone_clon, dom)
    template "#{zone_file}" do
        not_if { File.exist?(zone_file)}
        source "zone_file.erb"
        owner  node['gitzone']['user']
        group node['gitzone']['group']
        mode '0750'
        variables({
            :domain => dom,
            :host_entries => {
                node['hostname'] => node['ipaddress'],
                },
            })
        action :create
    end
end

# update zone file with host searched in the domain
#TODO: generate reverse zone files
node['gitzone']['domains'].each do |dom|
    zone_file = ::File.join(zone_clon, dom)
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
    cwd zone_clon
    user node['gitzone']['user']
    group node['gitzone']['group']
    code <<-EOF
        git checkout master
        git pull --rebase origin master
        git add *
        git commit -m "modified zone_file"
        git push origin master
     EOF
    ignore_failure false
    action :nothing
end

