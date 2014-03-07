

require 'minitest/autorun'

describe 'gitzone::install' do
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    it "has cloned gitzone repo" do
        assert File.exists?("#{node['gitzone']['repo_dir']}/gitzone/.git")
    end

    it "has installed gitzone" do
        assert File.exists?("#{node['gitzone']['preffix']}/bin/gitzone")
        assert File.executable?("#{node['gitzone']['preffix']}/bin/gitzone")
    end

end

