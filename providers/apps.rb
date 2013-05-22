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

def database_adapter_mapping
  @mapping = Hash.new(Proc.new {|host| Chef::Log.error("no adapter mapping found!"); {} })
  @mapping.merge!({
    "mysql"        => Proc.new { |host| {:host => host[:ipaddress], :password => host['mysql']['server_root_password'], :username => (host['mysql']['server_root_user'] || "root")} },
    "mysql2"        => Proc.new { |host| {:host => host[:ipaddress], :password => host['mysql']['server_root_password'], :username => (host['mysql']['server_root_user'] || "root")} },
    "postgresql"   => Proc.new { |host| { :host => host[:ipaddress], :password => host['postgresql']['password']['postgres'], :username => "postgres"} },
    "mongoid"      => Proc.new { |host| {:host => host[:ipaddress] } },
    "redis"        => Proc.new { |host| {:host => host[:ipaddress] } },
    "memcached"    => Proc.new { |host| {:host => host[:ipaddress], :port => host[:memcached][:port] } }
  })
  @mapping
end

def database_config(site)
  query = "roles:*#{site.fetch(:db, {})[:type]} AND tags:#{site[:id]} AND chef_environment:#{node.chef_environment}"

  host = search("node", query).first

  Chef::Log.info("running: #{query}")
  if host
    config = case site.fetch(:db, {})[:type]
      when "mysql" then {:password => host['mysql']['server_root_password'], :username => (host['mysql']['server_root_user'] || "root")}
      when "postgresql" then {:password => host['postgresql']['password']['postgres'], :username => "postgres"}
      else {}
    end
    config.merge(:fqdn => host[:ipaddress], :pool => site.fetch(:db, {})[:pool])
  else
    Chef::Log.error("No host found! Trying config from data bag!")
    site[:db]
  end
end

def mongoid_config(site)
  host = search("node", "roles:*#{site.fetch(:db, {})[:type]} AND tags:#{site[:id]} AND chef_environment:#{node.chef_environment}").first
  unless host
    Chef::Log.error("Got no database host!!!")
    return {}
  end

  {
    :fqdn     => host[:ipaddress]
  }
end

action :remove do
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  end

  query = "NOT (#{node['roles'].map{|r| "roles:#{r}" }.join(" OR ")})"
  Chef::Log.info("Running query: #{query}")
  search(new_resource.data_bag, query) do |site|
    deploy_config = site[:deploy] || {}
    deploy_config[:home] ||= new_resource.home
    deploy_config[:deploy_to] ||= "#{deploy_config[:home]}/#{site[:id]}"

    execute("rm -rf #{deploy_config[:deploy_to]}")
  end

  new_resource.updated_by_last_action(true)
end

action :create do
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  end

  query = "(#{node['roles'].map{|r| "roles:#{r}" }.join(" OR ")})"
  Chef::Log.info("Running query: #{query}")

  search(new_resource.data_bag, query) do |item|
    site = Chef::Mixin::DeepMerge.merge(item.to_hash, (item[node.chef_environment] || {}))
    deploy_config = site[:deploy] || {}

    # set defaults
    deploy_config[:user] ||= new_resource.user
    deploy_config[:group] ||= new_resource.group

    deploy_config[:home] ||= new_resource.home
    deploy_config[:deploy_group] ||= new_resource.deploy_group

    deploy_config[:deploy_to] ||= "#{deploy_config[:home]}/#{site[:id]}"

    # create user
    user deploy_config[:user] do
      home deploy_config[:home]
      shell "/bin/bash"
      manage_home true
    end

    # create .ssh directory and upload authorized keys
    directory "#{deploy_config[:home]}/.ssh" do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0700"
    end

    group_query = (deploy_config[:deploy_group] || Array.new).map{|r| "groups:#{r}" }.join(" OR ")
    authorized_keys = search(:users, "#{group_query} NOT action:remove").inject([]){|keys, u| keys << u['ssh_keys']}

    template "#{deploy_config[:home]}/.ssh/authorized_keys" do
      source "authorized_keys.erb"
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0600"
      variables :ssh_keys => authorized_keys.flatten
    end

    # as recursive only applies the perms to the top-most directory we have to
    # be it the hard way.
    directory deploy_config[:deploy_to] do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
      recursive true
    end
    directory "#{deploy_config[:deploy_to]}/shared" do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
    end
    directory "#{deploy_config[:deploy_to]}/shared/system" do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
    end
     directory "#{deploy_config[:deploy_to]}/shared/log" do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
    end
    directory "#{deploy_config[:deploy_to]}/shared/pids" do
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
    end

    template "#{deploy_config[:deploy_to]}/shared/database.yml" do
      source "database.yml.erb"
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
      variables(:host => database_config(site), :db => site.fetch(:db, {})[:name], :environment => site[:rails_env], :adapter => site.fetch(:db, {})[:adapter])
      only_if { site[:db] && ["mysql", "postgresql"].include?(site[:db][:type]) }
    end

    template "#{deploy_config[:deploy_to]}/shared/mongoid.yml" do
      source "mongoid.yml.erb"
      owner deploy_config[:user]
      group deploy_config[:group]
      mode "0775"
      variables(:host => mongoid_config(site), :db => site.fetch(:db, {})[:name], :environment => site[:rails_env])
      only_if { site[:db] && ["mongoid"].include?(site[:db][:adapter]) }
    end

    if site[:configs]
      site[:configs].each do |filename, attributes|
        if role = attributes.delete(:role_of_host_node)
          if host = search("node", "roles:*#{role} AND tags:#{site[:id]} AND chef_environment:#{node.chef_environment}").first
            attributes = (database_adapter_mapping[attributes[:adapter]].call(host)).inject({}) {|m,k| m[k.first.to_s]=k.last;m }.merge(attributes)
          else
            Chef::Log.error("host node was requested but no host with role #{role} and tag #{site[:id]}was found!")
          end
        end
        template "#{deploy_config[:deploy_to]}/shared/#{filename}.yml" do
          source "config.yml.erb"
          owner deploy_config[:user]
          group deploy_config[:group]
          mode "0775"
          file_content = YAML.dump({(site[:rails_env] || node.chef_environment) => attributes.to_hash})
          Chef::Log.info("writing config file: #{filename} with content:")
          Chef::Log.info(file_content)
          variables(:yaml => file_content)
        end
      end
    end

    if site[:delayed_job]
      template "/etc/init/delayed_job_#{site[:id]}.conf" do
        source "delayed_job.conf.erb"
        variables(:application => site, :deployment => deploy_config)
      end

      sudo deploy_config[:user] do
        user deploy_config[:user]
        runas "root"
        commands ["/usr/sbin/service delayed_job_*"]
        host "ALL"
        nopasswd true
      end
    end

    logrotate_app site[:id] do
      cookbook "logrotate"
      path "#{deploy_config[:deploy_to]}/shared/log/*.log"
      frequency "daily"
      rotate 30
    end

    new_resource.updated_by_last_action(true)
  end
end
