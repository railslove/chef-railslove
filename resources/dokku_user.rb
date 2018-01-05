#
# Cookbook Name:: dokku
# Resource:: dokku_user
#
# Copyright (c) 2015 Nick Charlton, MIT licensed.
#

actions :add, :remove
default_action :add

attribute :user, kind_of: String, name_attribute: true
attribute :key, kind_of: String
