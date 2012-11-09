#
# Cookbook Name:: railslove
# Resources:: deployment
#
# Copyright 2012, Railslove GmbH
#

actions :deploy

# :data_bag is the object to search
# :cookbook is the name of the cookbook that the authorized_keys template should be found in
attribute :siteconf, :kind_of => Hash, :required => true
attribute :data_bag, :kind_of => String, :default => "applications", :name_attribute => true
attribute :cookbook, :kind_of => String, :default => "railslove"

# these are default values, which should actually be definded in the application databag
attribute :user, :kind_of => String, :default => "rails"
attribute :home, :kind_of => String, :default => "/srv/www"
attribute :deploy_group, :kind_of => String, :default => "deployer"
attribute :migrate, :kind_of => [TrueClass, FalseClass, NilClass], :default => true
attribute :migration_command, :kind_of => String, :default => "bundle exec rake db:create && bundle exec rake db:migrate" # we make sure that the db exists before running the migration
attribute :restart_command, :kind_of => String, :default => "touch tmp/restart.txt"
attribute :precompile_assets, :kind_of => [NilClass, TrueClass, FalseClass], :default => true
