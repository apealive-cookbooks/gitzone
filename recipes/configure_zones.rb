# deploy zone repo clone and initialize zone files

zone_repo = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones', node['gitzone']['user'])
zone_clon = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones-wc-' + node['gitzone']['user'])
zone_user = node['gitzone']['user']
zone_group = node['gitzone']['group']

# a little tweak
# use node:gitzone/admin account to clone repo (assume ssh_keys are configured properly)
if !node['gitzone']['admin'].nil? && !node['gitzone']['user_ssh_pub_keys'].nil? && node['gitzone']['user_ssh_pub_keys'].length > 0
  # TODO, Rather get the home path from env.
  zone_clon = ::File.join(node['gitzone']['home'], node['gitzone']['admin'], 'zones-wc-' + node['gitzone']['user'])
  zone_user = node['gitzone']['admin']
end

# FIXME, commit first in zone_repo (ie: to avoid fail later)
execute 'fix-init-zone-repo' do
  # cwd gitzone_repo
  command <<-EOF
                  cd #{zone_repo}
                  ; echo ";# INIT \n" >> CHANGELOG.md
                  ; git config -f /home/#{node['gitzone']['user']}/.gitconfig user.name "#{node['gitzone']['user']}"
                  ; git config -f /home/#{node['gitzone']['user']}/.gitconfig user.email "#{node['gitzone']['user']}@`hostname -f`"
                  ; chown user #{node['gitzone']['user']}.#{node['gitzone']['group']} /home/#{node['gitzone']['user']}/.gitconfig
                  ; git add CHANGELOG.md
                  ; git commit -m "init changelog"
                  #; git branch -b master
                  #; echo ".old" > .gitignore
                  #; git add * ;
                  #; git commit -m "kickoff"
                  #; git config receive.denyCurrentBranch ignore
  EOF
  ignore_failure true
  action :run
  only_if { ::File.exist?(zone_repo) }
end

# check out the latest gitzone repo
git zone_clon do
  only_if { ::File.exist?(zone_repo) }
  repository zone_repo
  # reference "master"
  revision 'HEAD'
  action :sync
  user zone_user
  group zone_group
  # ignore failures to be able clone empty repository
  ignore_failure true
  # #notifies :run, "execute[gitzone-make-install]", :immediately
  retries 10
  retry_delay 10          # wait for bind service to start
end

# TODO: generate reverse zone files
# create zone file (if not exist)
managed_domains = (node['gitzone']['domains'] + [node[:system][:domain_name]]).uniq
managed_domains.each do |dom|
  zone_file = ::File.join(zone_clon, dom)
  # FIXME, properly get node hostname
  # if node['system']['short_hostname'].nil?
  #  short_hostname = node['name']
  # else
  #  short_hostname = node['system']['short_hostname']
  # end
  template zone_file do
    not_if { File.exist?(zone_file) }
    source 'zone_file.erb'
    owner zone_user
    group zone_group
    mode '0750'
    variables(
        domain: dom,
        host_entries: {
          node['hostname'] => node['ipaddress']
        }
        )
    action :create
    retries 10
    retry_delay 10          # wait for bind service to start
    only_if { ::File.exist?(zone_clon) }
  end
end

# TODO, generate reverse zone files
# auto update zone file with host searched in the domain
node['gitzone']['domains'].each do |dom|
  zone_file = ::File.join(zone_clon, dom)
  ruby_block 'update-zone-file' do
    block do
      # stamp = Time.now.strftime('%d/%m/%Y %H:%M:%S')
      fe = Chef::Util::FileEdit.new(zone_file)
      if Chef::Config[:solo]
        Chef::Log.warn("#{cookbook_name} uses search - you are running a solo - thus skipping resolver configuration.")
      else
        nodes = search(:node, "domain:#{dom}") # ,"chef_environment:#{node.environment}")
        nodes.each do |n|
          fe.insert_line_if_no_match(/^#{n['hostname']}/, "#{n['hostname']}     A   #{n['ipaddress']}")
        end
      end
      # TODO,this practically update file each run - avoid that - fe.search_file_replace_line(/^;; Updated:.*/, ";; Updated: #{stamp}")
      fe.write_file
    end
    retries 10
    retry_delay 10          # wait for bind service to start
    only_if { File.exist?(zone_file) }
    action :run
    notifies :run, 'bash[git_commit_zone_file]', :delayed
  end
end

# TODO,Create zone_file listing all 2nd level domains
#

bash 'git_commit_zone_file' do
  cwd zone_clon
  # FIXME,- ownership & execution under gitzone user
  # user zone_user
  # group zone_group
  code <<-EOF
        #check bind is already running (together with retry/delay)
        service #{node['bind']['service_name']} status || exit 4;
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
  retry_delay 10          # wait for bind service to start
  only_if { ::File.exist?(zone_clon) }
  ignore_failure false
  action :nothing
end
