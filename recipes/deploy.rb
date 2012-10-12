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
user node[:railslove][:user] do
  home node[:railslove][:home]
  shell "/bin/bash"
  manage_home true
end

directory "#{node[:railslove][:home]}/.ssh" do
  owner node[:railslove][:user]
  group node[:railslove][:user]
  mode "0700"
end

ssh_keys = search(:users, "groups:#{node[:railslove][:deploy_group]} NOT action:remove").inject([]){|keys, u| keys << u['ssh_keys']}
template "#{node[:railslove][:home]}/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner node[:railslove][:user]
  group node[:railslove][:user]
  mode "0600"
  variables :ssh_keys => ssh_keys.flatten
end