# Recipe to configure dyndns (server updates it's IP in gitzone enabled DNS)

# search for role with gitzone installed
server_root_pub_key=File.open("/root/.ssh/id_rsa").first if File.exist?('/root/.ssh/id_rsa')
if Chef::Config[:solo] and not chef_solo_search_installed?
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.")
else


  gitzone_servers = search(:node, "#{node[:gitzone][:search_query]}")
  gitzone_servers.each do |n|
    #check pub key already configured -> deploy scripted update
    if n[:gitzone][:user_ssh_pub_keys].include?(server_root_pub_key)
        #TODO: use "domainfile somehost IN A" not just "A"
        #TODO: Use add-key if password-less ssh-key infrastructure exist:
        #         ssh -o StrictHostKeyChecking=false gitzone@<GITZONE_HOST> add-key \'command="update-record `hostname -d` `hostname -s` IN A"\' `cat $HOME/.ssh/id_rsa.pub`

        # deploy update-record script
        update_record_script="ssh -o StrictHostKeyChecking=false #{n[:gitzone][:user]}@#{n[:fqdn]} update-record `hostname -d` `hostname -s` A"   
        case node['platform']
            when 'debian', 'ubuntu'
                network_script = '/etc/network/interfaces.d/ifup-local'
                task_line=" post-up #{update_record_script}"
                #create template
                bash "create ifup-local script/cfg" do
                    code <<-EOF
                        test -d `dirname #{network_script}` || mkdir -p `dirname #{network_script}`;
                        echo "iface eth0" > #{network_script}
                        echo "  ##{n[:fqdn]} update-record" >> #{network_script}
                     EOF
                    action :run
                    not_if { File.exist?(network_script) }
                end
            else #'redhat', 'centos'
                network_script = '/etc/sysconfig/network-scripts/ifup-local'
                task_line=update_record_script
                #create template
                bash "create ifup-local script/cfg" do
                    code <<-EOF
                        test -d `dirname #{network_script}` || mkdir -p `dirname #{network_script}`;
                        echo "#!/bin/bash" > #{network_script}
                        echo "##{n[:fqdn]} update-record" >> #{network_script}
                     EOF
                    action :run
                    not_if { File.exist?(network_script) }
                end
        end

        ruby_block "update-record_script" do
          only_if { ::File.exist?(network_script)}
          block do
            fe = Chef::Util::FileEdit.new(network_script)
            fe.search_file_replace_lineh(/#{n[:fqdn]} update-record/, "#{task_line}")
            fe.write_file
          end
          action :create
        end
    end

    #upload key
    if ( !server_root_pub_key.nil? and !server_root_pub_key.length > 0 ) or !n[:gitzone][:user_ssh_pub_keys].nil?
        n.set[:gitzone][:user_ssh_pub_keys] = (n[:gitzone][:user_ssh_pub_keys]+server_root_pub_key).uniq.sort
    end
  end
end

