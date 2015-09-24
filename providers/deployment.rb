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
  deploy_config[:bundler] ||= new_resource.bundler unless deploy_config.key?(:bundler)
  deploy_config[:migration_command] ||= new_resource.migration_command

  deploy_config[:precompile_assets] ||= new_resource.precompile_assets unless deploy_config.key?(:precompile_assets)
  deploy_config[:deploy_to] ||= "#{deploy_config[:home]}/#{new_resource.site_config[:id]}"

  deploy_config[:restart_command] ||= new_resource.restart_command
  deploy_config[:restart_command] = "cd #{deploy_config[:deploy_to]}/current && #{deploy_config[:restart_command]}" # hack to run restart command from the release directory

  deploy_config[:revision] ||= new_resource.revision
  deploy_config[:environment] ||= node.chef_environment

  deploy_config[:shallow_clone] ||= new_resource.shallow_clone

  application new_resource.site_config[:id] do
    path deploy_config[:deploy_to]
    owner deploy_config[:user]
    group deploy_config[:group]

    shallow_clone deploy_config[:shallow_clone]

    environment_name deploy_config[:environment]
    environment({
      "RAILS_ENV" => deploy_config[:environment],
      "RACK_ENV"  => deploy_config[:environment]
    })

    repository deploy_config[:repository]
    revision deploy_config[:revision]

    deploy_key deploy_config[:deploy_key]

    if deploy_config[:application_type] == "rails"
      purge_before_symlink %w{log tmp/pids public/system}
      create_dirs_before_symlink %w{tmp public config}
      symlinks({"system" => "public/system", "pids" => "tmp/pids", "log" => "log"})
      restart_command deploy_config[:restart_command]
    end

    symlink_before_migrate((deploy_config[:symlinks]||{}))

    migrate deploy_config[:migrate]
    migration_command deploy_config[:migration_command]

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
      sha_to_deploy = release_path.split("/").last

      callback_file = "#{release_path}/deploy/after_restart.rb"
      if ::File.exist?(callback_file)
        run_callback_from_file(callback_file)
      end

      if deploy_config[:campfire]
        begin
          require "broach"
          Broach.settings = {'account' => deploy_config[:campfire][:subdomain], 'token' => deploy_config[:campfire][:token], 'use_ssl' => true}
          room = Broach::Room.find_by_name(deploy_config[:campfire][:room])
          room.speak(":shipit: deployed #{application_name} to revision #{sha_to_deploy[0...7]} on http://#{node["fqdn"]}! #{deploy_config[:commit_message]}")
        rescue => e
          Chef::Log.info("Campfire: failed to connect to campfire.")
          Chef::Log.error("Campfire: #{e.inspect}")
        end
      end
      if deploy_config[:slack]
        begin
          repo = URI.parse(deploy_config[:repository].gsub(/^[^@]+\D/, "").gsub(":", "/").gsub(".git", ""))
          repo.path += "/commits/#{sha_to_deploy}"
          payload = JSON.dump({
              "channel" => deploy_config[:slack][:channel],
              "username" => (deploy_config[:slack][:username] || "Chef"),
              "icon_emoji" => (deploy_config[:slack][:icon_emoji] || ":doughnut:"),
              "fallback" => "deployed #{application_name} revision *#{sha_to_deploy[0...7]}* on <http://#{node["fqdn"]}|#{node.name}>!",
              "pretext" => "deployed #{application_name} on <http://#{node["fqdn"]}|#{node.name}>!",
              "color" => "good",
              "fields" => [
                  {
                      "title" => "Revision",
                      "value" => "<https://#{repo.to_s}|#{sha_to_deploy[0...7]}>",
                      "short" => true
                  },
                  {
                      "title" => "Environment",
                      "value" => node.chef_environment,
                      "short" => true
                  }
              ],
          })

          Chef::HTTP::HTTPRequest.new(:POST, URI("https://hooks.slack.com/services/#{deploy_config[:slack][:token]}"), "payload=#{payload}").call
        rescue => e
          Chef::Log.info("Slack: failed to connect to slack.")
          Chef::Log.error("Slack: #{e.inspect}")
        end
      end
    end

    if deploy_config[:application_type] == "rails"
      railslove_rails application_name do
        environment_name deploy_config[:environment]
        environment({
          "RAILS_ENV" => deploy_config[:environment],
          "RACK_ENV"  => deploy_config[:environment]
        })
        gems %w(bundler rake)
        bundler deploy_config[:bundler]
        precompile_assets deploy_config[:precompile_assets]
      end
    elsif deploy_config[:application_type] == "static"
      railslove_static
    end


  end

  new_resource.updated_by_last_action(true)
end
