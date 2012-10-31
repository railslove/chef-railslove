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
#
query = "(#{node[:roles].map{|r| "roles:#{r}" }.join(" OR ")})"

search(:applications, "#{query}") do |application|
  site = Chef::Mixin::DeepMerge.merge(application.to_hash, (application[node.chef_environment] || {}))
  deploy_config = site[:deploy]

  user deploy_config[:user] do
    home deploy_config[:home]
    shell "/bin/bash"
    manage_home true
  end

  directory "#{deploy_config[:home]}/.ssh" do
    owner deploy_config[:user]
    group deploy_config[:user]
    mode "0700"
  end

  if deploy_user = search(:users, "groups:#{deploy_config[:deploy_user} NOT action:remove").first
    private_key = deploy_user[:private_key]
    public_ky = deploy_user[:public_key]

    file "#{deploy_config[:home]}/.ssh/id_rsa" do
      owner deploy_config[:user]
      group deploy_config[:user]
      mode "0600"
      content private_key
    end

    public_key = search(:users, "groups:#{deploy_config[:deploy_user]} NOT action:remove").first
    file "#{deploy_config[:home]}/.ssh/id_rsa.pub" do
      owner deploy_config[:user]
      group deploy_config[:user]
      mode "0600"
      content public_key
    end
  end

  authorized_keys = search(:users, "groups:#{deploy_config[:deploy_group]} NOT action:remove").inject([]){|keys, u| keys << u['ssh_keys']}
  template "#{deploy_config[:home]}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner deploy_config[:user]
    group deploy_config[:user]
    mode "0600"
    variables :ssh_keys => authorized_keys.flatten
  end

end
