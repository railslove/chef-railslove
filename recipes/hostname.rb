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

gem_package "fog"

credentials = data_bag_item("aws", "route53")

if node.attribute?(:ec2) and node.ec2.attribute?("public_ipv4")
  route53_record "create a record" do
    name  node.set_fqdn
    value node.ec2["public_ipv4"]
    type  "A"
    ttl 300

    zone_id               credentials["zone_id"]
    aws_access_key_id     credentials["aws_access_key_id"]
    aws_secret_access_key credentials["aws_secret_access_key"]

    action :create
  end
end
