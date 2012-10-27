#
# Cookbook Name:: railslove
# Provider:: apps
#
# Copyright 2012, Railslove GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def initialize(*args)
  super
  @action = :create
end

def database_config(site)
  host = search("node", "roles:*#{site[:db][:type]} AND tags:#{site[:id]} AND chef_environment:#{node.chef_environment}").first
  Chef::Log.error("Got no database host!!!") unless host

  config = case site[:db][:type]
    when "mysql" then {:password => host['mysql']['server_root_password'], :username => (host['mysql']['server_root_user'] || "root")}
    when "postgresql" then {:password => host['postgresql']['password']['postgres'], :username => "postgres"}
  end

  config.merge(:fqdn => host[:ipaddress])
end

def mongoid_config(site)
  host = search("node", "roles:*#{site[:db][:type]} AND tags:#{site[:id]} AND chef_environment:#{node.chef_environment}").first
  unless host
    Chef::Log.error("Got no database host!!!")
    return {}
  end

  {
    :fqdn     => host[:ipaddress]
  }
end

action :remove do
  query = "NOT (#{node[:roles].map{|r| "roles:#{r}" }.join(" OR ")})"
  Chef::Log.info("Running query: #{query}")
  search("#{new_resource.data_bag}", "#{query}") do |site|
    execute("rm -rf #{node[:railslove][:home]}/#{site[:id]}")
  end
end

action :create do
  query = "(#{node[:roles].map{|r| "roles:#{r}" }.join(" OR ")})"
  Chef::Log.info("Running query: #{query}")

  search("#{new_resource.data_bag}", "#{query}") do |item|
    site = Chef::Mixin::DeepMerge.merge(item.to_hash, (item[node.chef_environment] || {}))
    deploy_config = site[:deploy]

    # set defaults
    deploy_config[:user] ||= new_resource.user
    deploy_config[:home] ||= new_resource.home

    deploy_config[:deploy_to] ||= File.join(deploy_config[:home], site[:id])

    # as recursive only applies the perms to the top-most directory we have to
    # be it the hard way.
    directory "#{deploy_config[:deploy_to]}" do
      owner deploy_config[:user]
      group deploy_config[:user]
      mode "0775"
      recursive true
    end
    directory "#{deploy_config[:deploy_to]}/shared" do
      owner deploy_config[:user]
      group deploy_config[:user]
      mode "0775"
    end

    if site[:db] && ["mysql", "postgresql"].include?(site[:db][:type])
      template "#{deploy_config[:deploy_to]}/shared/database.yml" do
        source "database.yml.erb"
        owner deploy_config[:user]
        group deploy_config[:user]
        mode "0775"
        variables(:host => database_config(site), :db => site[:db][:name], :environment => site[:rails_env], :adapter => site[:db][:adapter])
      end
    end

    if site[:db] && ["mongoid"].include?(site[:db][:adapter])
      template "#{deploy_config[:deploy_to]}/shared/mongoid.yml" do
        source "mongoid.yml.erb"
        owner deploy_config[:user]
        group deploy_config[:user]
        mode "0775"
        variables(:host => mongoid_config(site), :db => site[:db][:name], :environment => site[:rails_env])
      end
    end

    logrotate_app site[:id] do
      cookbook "logrotate"
      path "#{deploy_config[:deploy_to]}/shared/log/*.log"
      frequency "daily"
      rotate 30
    end

  end
end