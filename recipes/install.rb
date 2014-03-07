# RECIPE install & update
# Imitate the function behind gitzone Makefile


# create gitzone repo base dir
directory node['gitzone']['repo_dir'] do
  owner node['gitzone']['user']
  group node['gitzone']['group']
  mode "0755"
  recursive true
  action :create
end

gitzone_repo = ::File.join(node['gitzone']['repo_dir'], 'gitzone')

# check out the latest code from gitzone repo
git gitzone_repo do
  repository node['gitzone']['repo_url']
  reference "master"
  action :sync
  notifies :run, "execute[gitzone-make-install]", :immediately
end

# execute make install
execute "gitzone-make-install" do
    cmd =  "sed -i 's:^PREFFIX=.*:PREFFIX=#{node['gitzone']['preffix']}:' #{:gitzone_repo}/Makefile"
    cmd << "; cd #{gitzone_repo}"
    cmd << "; make install"
    command cmd
    ignore_failure false
    action :nothing
    notifies :run, "execute[fix-gitzone-sudordnc]", :immediately
    #not_if { ::File.exists?("#{node['gitzone']['preffix']}/bin/gitzone-shell") }
end

# fix gitzone script
# - to run rndc with sudo privileges as bind user
# - to run rndc reload only 
#   - (w/class&zone etc it returns: rndc: 'reload' failed: not found)
#   - may slow-down things if many zones is configured
execute "fix-gitzone-sudordnc" do
    gitzone_script = ::File.join(node['gitzone']['preffix'], 'bin','gitzone')
    cmd =  "sed -i 's:\$rndc reload.*\$_:sudo -u #{node['bind']['user']} sh -c \"\$rndc reload\":' #{gitzone_script}"
    command cmd
    #ignore_failure false
    action :nothing
    only_if { ::File.exists?(gitzone_script) }
end
