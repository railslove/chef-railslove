#
# Cookbook Name:: railslove
# Provider:: sudoers
#
# Copyright 2013, Railslove GmbH
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

def initialize(*args)
  super
  @action = :create
end

action :remove do
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  end

  search(new_resource.data_bag, "NOT #{new_resource.sudo_attribute}:true") do |u|
    sudo u['id'] do
      action :remove
      only_if do ::File.exists?("/etc/sudoers.d/#{u['id']}") end
    end
  end

  new_resource.updated_by_last_action(true)
end

action :create do
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  end

  search(new_resource.data_bag, "#{new_resource.sudo_attribute}:true") do |u|
    sudo u['id'] do
      user u['id']
      host "ALL"
      commands ["ALL"]
      nopasswd new_resource.nopasswd
    end
  end

  new_resource.updated_by_last_action(true)
end
