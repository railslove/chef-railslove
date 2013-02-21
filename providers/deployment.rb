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
#   application <applicaton databag>
# end


action :deploy do
  deploy_config = new_resource.site_config[:deploy] || {}
  application_name = new_resource.site_config[:id] # make the name available for the campfire notification

  # set defaults
  deploy_config[:user] ||= new_resource.user
  deploy_config[:group] ||= new_resource.group
  deploy_config[:home] ||= new_resource.home
  deploy_config[:deploy_group] ||= new_resource.deploy_group
  deploy_config[:migrate] ||= new_resource.migrate unless deploy_config.key?(:migrate)
  deploy_config[:migration_command] ||= new_resource.migration_command

  deploy_config[:precompile_assets] ||= new_resource.precompile_assets unless deploy_config.key?(:precompile_assets)
  deploy_config[:deploy_to] ||= "#{deploy_config[:home]}/#{new_resource.site_config[:id]}"

  deploy_config[:restart_command] ||= new_resource.restart_command
  deploy_config[:restart_command] = "cd #{deploy_config[:deploy_to]}/current && #{deploy_config[:restart_command]}" # hack to run restart command from the release directory

  deploy_config[:revision] ||= new_resource.revision
  deploy_config[:environment] ||= node.chef_environment

  application new_resource.site_config[:id] do
    path deploy_config[:deploy_to]
    owner deploy_config[:user]
    group deploy_config[:group]

    environment_name deploy_config[:environment]
    environment({
      "RAILS_ENV" => deploy_config[:environment],
      "RACK_ENV"  => deploy_config[:environment],
      'LC_ALL' => 'en_GB.UTF-8',
      'LANG'   => 'en_GB.UTF-8'
    })

    repository deploy_config[:repository]
    revision deploy_config[:revision]

    deploy_key deploy_config[:deploy_key]

    purge_before_symlink %w{log tmp/pids public/system}
    create_dirs_before_symlink %w{tmp public config}

    symlink_before_migrate((deploy_config[:symlinks]||{}))
    symlinks({"system" => "public/system", "pids" => "tmp/pids", "log" => "log"})

    migrate deploy_config[:migrate]
    migration_command deploy_config[:migration_command]

    restart_command deploy_config[:restart_command]
    rollback_on_error true

    before_symlink do
      callback_file = "#{release_path}/deploy/before_symlink.rb"
      if ::File.exist?(callback_file)
        run_callback_from_file(callback_file)
      end
    end
    before_restart do
      callback_file = "#{release_path}/deploy/before_restart.rb"
      if ::File.exist?(callback_file)
        run_callback_from_file(callback_file)
      end
    end
    after_restart do
      callback_file = "#{release_path}/deploy/after_restart.rb"
      if ::File.exist?(callback_file)
        run_callback_from_file(callback_file)
      end

      if deploy_config[:campfire]
        begin
          require "broach"
          Broach.settings = {'account' => deploy_config[:campfire][:subdomain], 'token' => deploy_config[:campfire][:token], 'use_ssl' => true}
          room = Broach::Room.find_by_name(deploy_config[:campfire][:room])
          room.speak("wahoo, deployed #{application_name} to revision #{deploy_config[:revision]}! #{deploy_config[:commit_message]}")
        rescue => e
          Chef::Log.info("Campfire: failed to connect to campfire.")
          Chef::Log.debug("Campfire: #{e.inspect}")
        end
      end
    end

    if deploy_config[:application_type] == "rails"
      railslove_rails do
        environment({
          "RAILS_ENV" => deploy_config[:environment],
          "RACK_ENV"  => deploy_config[:environment],
          'LC_ALL' => 'en_GB.UTF-8',
          'LANG'   => 'en_GB.UTF-8'
        })
        gems %w(bundler rake)
        bundler true
        precompile_assets deploy_config[:precompile_assets]
      end
    end

  end
end



