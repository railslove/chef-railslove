#
# Cookbook Name:: railslove
# Recipe:: hostname
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

# class Chef::Recipe
#   include INWX::Domrobot
# end

#::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

node.set[:set_fqdn] = node.name + "." + node.chef_environment + ".#{node[:railslove][:domain]}"
include_recipe "hostname"

#load "inwx/Domrobot.rb"
require "yaml"

#addr = "api.ote.domrobot.com"
addr = "api.domrobot.com"

credentials = data_bag_item("inwx", "credentials")

user = credentials["login"]
pass = credentials["password"]

domrobot = INWX::Domrobot.new(addr)

result = domrobot.login(user,pass)

content = node.ec2.public_ipv4
name    = "#{node.name}.#{node.chef_environment}"
domain  = node.railslove.domain

object = "nameserver"
method = "info"

params = { :name => name, :domain => domain }

result = domrobot.call(object, method, params)

puts YAML::dump(result)
if result["code"] == 1000
  record  = result["resData"]["record"].first

  object = "nameserver"
  method = "updateRecord"

  params = { :id => record["id"], :type => "A", :content => content, :name => name }

  if record["content"] == content
    puts "not updating..."
  else
    result = domrobot.call(object, method, params)

    puts YAML::dump(result)
  end
else
  object = "nameserver"
  method = "createRecord"

  params    = { :type => "A", :content => content, :name => name, :domain => domain }

  result = domrobot.call(object, method, params)

  puts YAML::dump(result)
end