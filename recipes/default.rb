#
# Cookbook Name:: railslove
# Recipe:: default
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
package "zsh"
package "htop"
package "iftop"
package "vim"
package "ntp"
if platform?('ubuntu')
  package "language-pack-de"
end
package "git-core"
package "libxml2-dev"
package "libxslt-dev"
package "mailutils"

package "build-essential"

if node['platform_version'] == '18.04'
  package 'openjdk-11-jre-headless'
elsif node['platform_version'] == "16.04"
  package "openjdk-9-jre-headless"
else
  package "openjdk-7-jre-headless"
end

package "nodejs"
package "imagemagick"
package "libmagickwand-dev"

template (node['platform_version'] == "16.04" ? "/etc/ImageMagick-6/policy.xml" : "/etc/ImageMagick/policy.xml") do
  source "imagemagick_policy.xml.erb"
  owner "root"
  group "root"
  mode "0644"
end

package "libv8-dev"

package "libcurl3"
package "libcurl3-gnutls"
package "libcurl4-openssl-dev"

node['railslove']['packages'].each do |package|
  package package
end

node['railslove']['companies'].each do |company|
  users_manage(company) do
    group_id 2300
    group_name "sysadmin"
    action [ :remove, :create ]
  end
end

["50-landscape-sysinfo", "51-cloudguest"].each do |file|
  file "/etc/update-motd.d/#{file}" do
    action :delete
  end
end

gem_package "bundler"
gem_package "slop"

cron 'ssh blacklist' do
  minute '*/60'
  user 'root'
  command "/usr/bin/wget -qO /etc/hosts.deny https://www.openbl.org/lists/hosts.deny"
end

gem_package "rake" do
  action :purge
  only_if { node['railslove']['rake']['version'] }
end

gem_package "rake" do
  version node['railslove']['rake']['version']
end

gem_package "ruby-shadow"
