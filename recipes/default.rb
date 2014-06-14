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
package "htop"
package "iftop"
package "vim"
package "ntp"
package "language-pack-de"
package "git-core"
package "libxml2-dev"
package "libxslt-dev"
package "mailutils"

package "openjdk-7-jre-headless"
package "nodejs"
package "imagemagick"
package "libmagickwand-dev"
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

gem_package "rake" do
  action :purge
  only_if { node['railslove']['rake']['version'] }
end

gem_package "rake" do
  version node['railslove']['rake']['version']
end

gem_package "ruby-shadow"
