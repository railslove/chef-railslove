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

def route53_bag
  data_bag_item(node['railslove']['route53']['databag'], node['railslove']['route53']['item'])
rescue
  Chef::Log.warn("You need to provide access credentials for Amazon Route53")
  {}
end

node.set['set_fqdn'] = node.name + "." + node.chef_environment + ".#{node['railslove']['domain']}"
include_recipe "hostname"

gem_package "fog"
cloud       = node['cloud'] || {}
credentials = route53_bag

route53_record "create a record" do
  name node['set_fqdn']
  value Array(cloud["public_ipv4"])[0]
  type  "A"
  ttl 300

  zone_id               credentials["zone_id"]
  aws_access_key_id     credentials["aws_access_key_id"]
  aws_secret_access_key credentials["aws_secret_access_key"]

  action :create

  only_if { node['railslove']['manage_dns_records'] and credentials.any? }
end
