#
# Cookbook Name:: railslove
# Recipe:: deploy
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

# make sure the users and directories are created
include_recipe "railslove::manage"

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
end

# install broach for campfire notification
broach = chef_gem 'broach' do
  action :nothing
end
broach.run_action(:install)

query = "(#{node['roles'].map{|r| "roles:#{r}" }.join(" OR ")})"
search(:applications, query) do |application|
  site_hash = Chef::Mixin::DeepMerge.merge(application.to_hash, (application[node.chef_environment] || {}))

  if site_hash[:deploy] && site_hash[:deploy][:repository]
    railslove_deployment "applications" do
      action [:deploy]
      site_config site_hash
    end
  else
    Chef::Log.warn("missing deploy config for #{site_hash[:id]}")
  end

end

