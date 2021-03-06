#
# Cookbook Name:: railslove
# Resources:: deployment
#
# Copyright 2012, Railslove GmbH
#

actions :deploy
default_action :deploy

include RailsloveSharedAttributes

attribute :site_config, :kind_of => Hash, :required => true
# these are default values, which should actually be definded in the application databag
attribute :bundler, :kind_of => [NilClass, TrueClass, FalseClass], :default => true
attribute :migrate, :kind_of => [TrueClass, FalseClass, NilClass], :default => true
attribute :migration_command, :kind_of => String, :default => 'bundle exec rake db:create db:migrate --trace; echo "rake db:create db:migrate exited with $?"'# we make sure that the db exists before running the migration
attribute :restart_command, :kind_of => String, :default => "touch tmp/restart.txt"
attribute :precompile_assets, :kind_of => [NilClass, TrueClass, FalseClass], :default => true
attribute :revision, :kind_of => String, :default => "master"
attribute :shallow_clone, :kind_of => [TrueClass, FalseClass], :default => false
