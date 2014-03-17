# deploy zone repo clone and initialize zone files

zone_repo = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones', node['gitzone']['user'])
zone_clon = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones-wc-' + node['gitzone']['user'])
zone_user = node['gitzone']['user']
zone_group = node['gitzone']['group']


#a little tweak
#use node:gitzone/admin account to clone repo (assume ssh_keys are configured properly)
if !node['gitzone']['admin'].nil? && !node['gitzone']['user_ssh_pub_keys'].nil? && node['gitzone']['user_ssh_pub_keys'].length > 0
    #TODO: Rather get the home path from env.
    zone_clon = ::File.join(node['gitzone']['home'], node['gitzone']['admin'], 'zones-wc-' + node['gitzone']['user'])
    zone_user = node['gitzone']['admin']
end


# check out the latest gitzone repo
git zone_clon do
  only_if { ::File.exist?(zone_repo) }
  repository zone_repo
  #reference "master"
  revision "HEAD"
  action :sync
  user zone_user
  group zone_group
  #ignore failures to be able clone empty repository
  ignore_failure true
  ##notifies :run, "execute[gitzone-make-install]", :immediately
end


#TODO: generate reverse zone files
# create zone file (if not exist)
node['gitzone']['domains'].each do |dom|
    zone_file = ::File.join(zone_clon, dom)
    #FIXME: properly get node hostname
    if node['system']['short_hostname'].nil?
        short_hostname = node['name']
    else
        short_hostname = node['system']['short_hostname']
    end
    template zone_file do
        not_if { File.exist?(zone_file)}
        source "zone_file.erb"
        owner zone_user
        group zone_group
        mode '0750'
        variables({
            :domain => dom,
            :host_entries => {
                node['system']['short_hostname'] => node['ipaddress'],
                },
            })
        action :create
    end
end

#TODO: generate reverse zone files
# auto update zone file with host searched in the domain
node['gitzone']['domains'].each do |dom|
    zone_file = ::File.join(zone_clon, dom)
    ruby_block "update-zone-file" do
        block do
            stamp= Time.now.strftime("%d/%m/%Y %H:%M:%S")
            fe = Chef::Util::FileEdit.new(zone_file)
            if Chef::Config[:solo]
                    Chef::Log.warn("#{cookbook_name} uses search - you are running a solo - thus skipping resolver configuration.")
            else
                #FIXME: search for nodes in the |dom|
                nodes = search(:node, "domain:#{dom}","chef_environment:#{node.environment}")
                nodes.each do |n|
                    fe.insert_line_if_no_match(/^#{n['name']}/, "#{n['name']}    A   #{n['ipaddress']}")
                end
            end
            fe.search_file_replace_line(/^;; Updated:.*/, ";; Updated: #{stamp}")
            fe.write_file
        end
        only_if { File.exist?(zone_file)}
    action  :run
    notifies :run, "bash[git_commit_zone_file]",:delayed
    end
end


#TODO Create zone_file listing all 2nd level domains
#


bash "git_commit_zone_file" do
    cwd zone_clon
    #FIXME
    #user zone_user
    #group zone_group
    code <<-EOF
        #check bind is already running (together with retry/delay)
        /etc/init.d/bind9 status || exit 1;
        git checkout master;
        git add `ls *|grep -v '.old$'`;
        git commit -m "modified zone_file";
        git pull --rebase origin master;
        git push origin master 2>&1;
        git pull;
        #FIXing file rights .. due execution with root rights
        chown -R #{node['gitzone']['user']}.#{node['gitzone']['group']} #{zone_clon};
        chown -R #{node['gitzone']['user']}.#{node['gitzone']['group']} #{zone_repo};
        chown -R #{node['gitzone']['user']}.#{node['bind']['group']} #{node['bind']['vardir']}/#{node['gitzone']['user']};
     EOF
    retries 10
    retry_delay 10          #wait for bind service to start
    ignore_failure false
    action :nothing
end
