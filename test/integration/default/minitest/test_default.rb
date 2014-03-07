
require 'minitest/autorun'

describe 'gitzone::configure_gitzone' do
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    it "has created gitzone.conf" do
        assert File.exists?("/etc/gitzone.conf")
    end

end
