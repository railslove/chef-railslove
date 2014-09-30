#
# Cookbook Name:: railslove
# Recipe:: backup
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

def s3_bag
  data_bag_item(node['railslove']['backup']['databag'], node['railslove']['backup']['item'])
rescue
  Chef::Log.warn("You need to provide access credentials for Amazon S3")
  {}
end

backup_install node.name
backup_generate_config node.name

credentials = s3_bag

backup_generate_model "postgresql" do
  description "backup of postgres"
  backup_type "database"
  database_type "PostgreSQL"
  split_into_chunks_of 2048
  store_with(
    {
     "engine" => "S3",
     "settings" => {
        "s3.access_key_id" => credentials["aws_access_key_id"],
        "s3.secret_access_key" => credentials["aws_secret_access_key"],
        "s3.region" => credentials["region"],
        "s3.bucket" => credentials["bucket"],
        "s3.path" => "/#{node.name}",
        "s3.keep" => 10 }
    }
  )
  notify_by(
    {
      "engine" => "HttpPost",
      "settings" => {
        "httppost.on_success" => true,
        "httppost.on_failure" => false,
        "httppost.on_warning" => false,
        "httppost.uri" => node['railslove']['backup']['notification_uri']
      }
    }
  ) if node['railslove']['backup']['notification_uri']
  options(
    {
      "db.name" => ":all",
      "db.username" => "\"postgres\"",
      "db.password" => "\"#{node.fetch('postgresql', {}).fetch('password', {})['postgres']}\"",
      "db.host" => "\"localhost\""
    }
  )

  action :backup
  only_if { node["roles"].include?("database-postgresql") && credentials.any? }
end


backup_generate_model "mysql" do
  description "backup of mysql"
  backup_type "database"
  database_type "MySQL"
  split_into_chunks_of 2048
  store_with(
    {
     "engine" => "S3",
     "settings" => {
        "s3.access_key_id" => credentials["aws_access_key_id"],
        "s3.secret_access_key" => credentials["aws_secret_access_key"],
        "s3.region" => credentials["region"],
        "s3.bucket" => credentials["bucket"],
        "s3.path" => "/#{node.name}",
        "s3.keep" => 10 }
    }
  )
  options(
    {
      "db.name" => ":all",
      "db.username" => "\"#{(node.fetch('mysql', {})['server_root_user'] || "root")}\"",
      "db.password" => "\"#{node.fetch('mysql', {})['server_root_password']}\"",
      "db.host" => "\"localhost\"",
      "db.additional_options" => "[\"--quick\", \"--single-transaction\"]"
    }
  )

  action :backup
  only_if { node["roles"].include?("database-mysql") && credentials.any? }
end

backup_generate_model "mongodb" do
  description "backup of mongodb"
  backup_type "database"
  database_type "MongoDB"
  split_into_chunks_of 2048
  store_with(
    {
     "engine" => "S3",
     "settings" => {
        "s3.access_key_id" => credentials["aws_access_key_id"],
        "s3.secret_access_key" => credentials["aws_secret_access_key"],
        "s3.region" => credentials["region"],
        "s3.bucket" => credentials["bucket"],
        "s3.path" => "/#{node.name}",
        "s3.keep" => 10 }
    }
  )
  options(
    {
      "db.name" => ":all",
      "db.host" => "\"localhost\"",
      "db.port" => "\"#{node.fetch('mongodb', {})['config']['port']}\"",
    }
  )

  action :backup
  only_if { node["roles"].include?("mongodb") && credentials.any? }
end
