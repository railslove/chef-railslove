#
# Cookbook Name:: railslove
# Provider:: deployment
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
# provides an deployment provider to deploy ruby applications
#
# Usage:
# railslove_deployment "applications" do
#   action [:deploy]
# end


action :deploy do
  query = "(#{node[:roles].map{|r| "roles:#{r}" }.join(" OR ")})"

  search("#{new_resource.data_bag}", "#{query}") do |application|
    site = Chef::Mixin::DeepMerge.merge(application.to_hash, (application[node.chef_environment] || {}))
    deploy_config = site[:deploy]

    # set defaults
    deploy_config[:user] ||= new_resource.user
    deploy_config[:home] ||= new_resource.home
    deploy_config[:deploy_group] ||= new_resource.deploy_group
    deploy_config[:migrate] ||= new_resource.migrate
    deploy_config[:migration_command] ||= new_resource.migration_command

    deploy_config[:deploy_to] ||= "#{deploy_config[:home]}/#{site[:id]}"

    deploy_config[:restart_command] ||= new_resource.restart_command
    deploy_config[:restart_command] = "cd #{deploy_config[:deploy_to]}/current && #{deploy_config[:restart_command]}" # hack to run restart command from the release directory

    application site[:id] do
      path deploy_config[:deploy_to]
      owner deploy_config[:user]
      group deploy_config[:group]

      environment_name node.chef_environment
      environment({
        "RAILS_ENV" => node.chef_environment,
        "RACK_ENV"  => node.chef_environment
      })
      repository deploy_config[:repository]
      revision deploy_config[:revision]

      deploy_key deploy_config[:deploy_key]

      symlinks({"system" => "public/system", "pids" => "tmp/pids", "log" => "log"}.merge(deploy_config[:symlinks]||{}))

      migrate deploy_config[:migrate]
      migration_command deploy_config[:migration_command]

      restart_command deploy_config[:restart_command]
      rollback_on_error true

      if deploy_config[:application_type] == "rails"
        railslove_rails do
          gems %w(bundler rake)
          bundler true
        end
      end

    end

  end

end



