#
# Cookbook Name:: railslove
# Recipe:: dokku
#
# Copyright 2017, Railslove GmbH
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

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
end

search(:users, "(#{node['roles'].map{|r| "groups:#{r}" }.join(" OR ")})").each do |user|
  railslove_dokku_user do
    key user['ssh_keys']
    user user['id']
    action user.fetch('action', 'add')
  end
end
