#
# Cookbook Name:: dokku
# Provider:: dokku_user
#
# Copyright (c) 2015 Nick Charlton, MIT licensed.
#

def whyrun_supported?
  true
end

use_inline_resources
action :add do
  execute "adding ssh key for #{new_resource.user}" do
    command "sshcommand acl-remove dokku #{new_resource.user} && echo #{new_resource.key} | sshcommand acl-add dokku #{new_resource.user}"
    not_if { system("grep #{new_resource.key.split(' ')[1]} /home/dokku/.ssh/authorized_keys") }
  end
  new_resource.updated_by_last_action(true)
end

use_inline_resources
action :remove do
  execute "removing ssh key for #{new_resource.user}" do
    command "sshcommand acl-remove dokku #{new_resource.user}"
  end
  new_resource.updated_by_last_action(true)
end
