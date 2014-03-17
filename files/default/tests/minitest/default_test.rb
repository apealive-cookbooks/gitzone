
require 'minitest/autorun'
require 'minitest/spec'

class TestGitzone < MiniTest::Chef::TestCase
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def zone_file
        ::File.join(node['bind']['vardir'], node['gitzone']['user'],node['gitzone']['domains'].first)
    end

    def gitzone_conf
      '/etc/gitzone.conf'
    end

    def test_gitzone_conf_exist
        assert File.exist?(gitzone_conf)
    end

    def test_zonefile_ownership
        require 'etc'
        assert File.stat(zone_file).uid == Etc.getpwnam("#{node['gitzone']['user']}").uid
        assert File.stat(zone_file).gid == Etc.getpwnam("#{node['gitzone']['group']}").gid
    end

end



describe 'gitzone::configure_zones' do
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources


    it "installed the unzip package" do
        package("git").must_be_installed
    end

    it "deploys bind zone_file" do
        #zone_file = ::File.join(node['bind']['vardir'], node['gitzone']['user'],node['gitzone']['domains'].first)
        #zone_file = ::File.join(node['bind']['vardir'], node['gitzone']['user'],node['gitzone']['domains'].first)
        #assert File.exist?(zone_file)
        file("#{node['bind']['vardir']}/#{node['gitzone']['user']}/#{node['gitzone']['domains'].first}").must_exist.with(:owner, node['gitzone']['user']).and(:group, node['gitzone']['group'])
    end

end
