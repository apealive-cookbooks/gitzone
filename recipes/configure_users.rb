#RECIPE configure users & repos
## 

zone_dir = ::File.join(node['gitzone']['home'], node['gitzone']['user'], 'zones', node['gitzone']['user'])

group node['gitzone']['group'] do
    action :create
end

# create gitzone user
user node['gitzone']['user'] do
    group node['gitzone']['group']
    shell node['gitzone']['preffix']+"/bin/gitzone-shell"
    home  ::File.join(node['gitzone']['home'], node['gitzone']['user'])
    supports :manage_home=>true
    comment "User for git managed zone.conf"
    action :create
    #password ''
    #password# Run: openssl passwd -1 "theplaintextpassword"
end

# deploy ssh key
# code pasted from community chef-ssh-keys cookbook
ssh_keys = node['gitzone']['user_ssh_pub_keys']
home_dir = ::File.join(node['gitzone']['home'], node['gitzone']['user'])

## Creating ".ssh" directory
directory ::File.join(home_dir,'.ssh') do
  owner node['gitzone']['user']
  group node['gitzone']['group']
  #recursive true
  mode "0700"
end

## generate keys if not defined
if !ssh_keys
    #package 'openssh'
    ssh_dir = ::File.join(home_dir, '.ssh')
    bash "generate ssh keys" do
        Chef::Log.info("SSH pub keys not specified, generating")
        cwd ssh_dir
        code <<-EOF
            ssh-keygen -t rsa -N "" -q -C "#{node['gitzone']['user']}@#{node.fqdn}" -f #{node['gitzone']['user']}_ssh.key
            chmod og-rwx #{ssh_dir}
            #TODO: make and ena/dis attribute from this
            #allow edit auth.keys
            touch #{ssh_dir}/authorized_keys_edit_allowed
            # --
            chown -R #{node['gitzone']['user']} #{ssh_dir}
            chgrp -R #{node['gitzone']['group']} #{ssh_dir}
            chmod -R 400 #{ssh_dir}/*
         EOF
        action :run
    end
    pub_key = File.join(home_dir, '.ssh',"#{node['gitzone']['user']}_ssh.key.pub" )
    if File.exist?(pub_key)
        File.open(pub_key).each do |pub|
            ssh_keys = Array(pub.delete "\n")
        end
    end
end

if !ssh_keys.nil? && ssh_keys.length > 0
      authorized_keys_file = ::File.join(home_dir,'.ssh','authorized_keys')

      if File.exist?(authorized_keys_file)
        Chef::Log.info("Appending to existing authorized keys")
        # Loading existing keys
        File.open(authorized_keys_file).each do |line|
          if line.start_with?("ssh")
            ssh_keys += Array(line.delete "\n")
          end
        end
        ssh_keys.uniq!
      end

      # Re/Creating "authorized_keys"
      template authorized_keys_file do
        owner node['gitzone']['user']
        group node['gitzone']['group']
        mode "0600"
        variables({ :ssh_keys => ssh_keys })
        action :create
      end
end

# gitzone-install
directory zone_dir do
  owner node['gitzone']['user']
  group node['bind']['user']
  mode "0750"
  recursive true
  action :create
  notifies :run, "bash[gitzone-git-init]"
end

# init gitzone git repository
bash "gitzone-git-init" do
   cwd zone_dir
   user node['gitzone']['user']
   group node['gitzone']['group']
   code <<-EOF
        git init .
        git config receive.denyCurrentBranch ignore
        git config user.name "#{node['gitzone']['user']}"
        git config user.email "#{node['gitzone']['user']}@`hostname -f`"
     EOF
    not_if { ::Dir.exists?("#{node['gitzone']['home']}/zones/#{node['gitzone']['user']}/.git") }
end

# link hooks
# if you want to use repository locally, link *commit* hooks as well
# hookscripts = %w{post-receive pre-receive}
hookscripts = ['post-receive', 'pre-receive', 'post-commit', 'pre-commit']
hookscripts.each do |script|
    link "#{zone_dir}/.git/hooks/#{script}" do
      to "#{node['gitzone']['preffix']}/libexec/gitzone/#{script}"
    end
end

# create gitzone.conf
template "/etc/gitzone.conf" do
    source "gitzone.conf.erb"
    owner node['gitzone']['user']
    group node['gitzone']['group']
    mode '0750'
    #variables({
        #:domains => node['gitzone']['domains'],
        #})
    action :create
end

# create /etc/sudoers.d/gitzone with rule allowing to run "rndc reload"
sudo 'gitzone' do
  group      "%#{node['gitzone']['group']}"
  runas     "#{node['bind']['user']}"
  commands  ['/usr/bin/rndc *']
  nopasswd  true
  #commands  ['/usr/bin/rndc reload *']
end
