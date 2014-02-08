#
# Cookbook Name:: railslove
# Resources:: rails
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
#
actions :before_compile, :before_deploy, :before_migrate, :before_symlink, :before_restart, :after_restart
default_action :before_deploy

include Chef::Resource::ApplicationBase

attribute :gems, :kind_of => [Array, Hash], :default => ["bundler", "rake"]
attribute :bundler, :kind_of => [NilClass, TrueClass, FalseClass], :default => true
attribute :bundler_without_groups, :kind_of => [Array], :default => []
attribute :bundler_jobs, :kind_of => Fixnum, :default => (node.cpu.total rescue 1)
attribute :bundle_command, :kind_of => [String, NilClass], :default => "bundle"
attribute :precompile_assets, :kind_of => [NilClass, TrueClass, FalseClass], :default => true
