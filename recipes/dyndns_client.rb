# Recipe to configure dyndns (server updates it's IP in gitzone enabled DNS)

# publish own key
server_root_pub_key = File.read('/root/.ssh/id_rsa.pub') if File.exist?('/root/.ssh/id_rsa')
if !server_root_pub_key.nil? &&  server_root_pub_key.length > 0
  node.set[:root_ssh_pub_keys] = node[:root_ssh_pub_keys] ? (node[:root_ssh_pub_keys] + [server_root_pub_key]).uniq.sort : [server_root_pub_key]
end

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.')
else

  # search for role with gitzone installed
  # default: gitzone_servers = search(:node, 'recipes:gitzone\:\:default')
  gitzone_servers = search(:node, node[:gitzone][:search_query])
  unless gitzone_servers.nil?
    gitzone_servers.each do |n|
      # check pub key infrastructure is configured
      # once managed by gitzone create update-record scripts
      if !n.nil? && !n[:gitzone].nil? && !n[:gitzone][:managed_nodes_pub_keys].nil?
        if n[:gitzone][:managed_nodes_pub_keys].include?(server_root_pub_key)
          # TODO: use "domainfile somehost IN A" not just "A"
          # TODO: Use add-key if password-less ssh-key infrastructure exist:
          #         ssh -o StrictHostKeyChecking=false gitzone@<GITZONE_HOST> add-key \'command="update-record `hostname -d` `hostname -s` IN A"\' `cat $HOME/.ssh/id_rsa.pub`

          # deploy update-record script
          # TODO: system approach - hostsfile.collect_and_flatten (filter for eth0 IPs)
          # TODO, FIXME: quick and dirty (multiply update-record scripts by otuput of:
          #       for i in `hostname -A ; hostname -a`; do echo $i|sed -e "s/\.`hostname -d`//" ;done | sort -u
          #       )
          #

          # node_aliases = ""
          # ruby_block "find-last-line" do
          # block do
          # node_aliases = `for i in \`hostname -A ; hostname -a\`; do echo $i|sed -e "s/\.\`hostname -d\`//" ;done | sort -u`
          # end
          # action :create
          # end
          # update_record_script=""
          # %w[node_aliases].each do |node_alias|
          # update_record_script+="ssh -o StrictHostKeyChecking=false #{n[:gitzone][:user]}@#{n[:fqdn]} update-record `hostname -d` #{node_alias} A;"
          # end

          directory '/root/bin' do
            owner 'root'
            group 'root'
            action :create
          end

          template '/root/bin/gitzone-update-record.sh' do
            source 'gitzone-update-record.sh.erb'
            owner 'root'
            group 'root'
            mode '0750'
            variables(
                gitzone_server_ssh_uri: "#{n[:gitzone][:user]}@#{n[:fqdn]}"
            )
            action :create
          end

          # TODO: replace bash with template resource
          update_record_script = '/root/bin/gitzone-update-record.sh'
          case node['platform']
              when 'debian', 'ubuntu'
                network_script = '/etc/network/interfaces.d/ifup-local'
                # create template
                bash 'create ifup-local script/cfg' do
                  code <<-EOF
                                    test -d `dirname #{network_script}` || mkdir -p `dirname #{network_script}`;
                                    echo "iface eth0" > #{network_script}
                                    echo "  post-up #{update_record_script}" >> #{network_script}
                                 EOF
                  action :run
                  not_if { File.exist?(network_script) }
                end
              else # 'redhat', 'centos'
                network_script = '/etc/sysconfig/network-scripts/ifup-local'
                # create template
                bash 'create ifup-local script/cfg' do
                  code <<-EOF
                                    test -d `dirname #{network_script}` || mkdir -p `dirname #{network_script}`;
                                    echo "#!/bin/bash" > #{network_script}
                                    echo "#{update_record_script}" >> #{network_script}
                                    chmod ug+x #{network_script}
                                 EOF
                  action :run
                  not_if { File.exist?(network_script) }
                end
          end

          # ruby_block "update-record_script" do
          # only_if { ::File.exist?(network_script)}
          # block do
          # fe = Chef::Util::FileEdit.new(network_script)
          # fe.search_file_replace_line(/#{n[:fqdn]} update-record/, "#{task_line}")
          # fe.write_file
          # end
          # action :create
          # end
        end
      end
    end
  end
end
