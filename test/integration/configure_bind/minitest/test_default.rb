
require 'minitest/autorun'

describe 'gitzone::configure_bind' do
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    it "has created gitzone bind repo dir with cfg" do
        assert File.exists?("/etc/#{node['gitzone']['bind_repos_dir']}/gitzone.conf")
    end

end
