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
package "vim"
package "zsh"
package "ack-grep"
package "ntp"
package "language-pack-de"
package "git-core"
package "libxml2-dev"
package "libxslt-dev"
package "openjdk-7-jre-headless"
package "nodejs"
package "imagemagick"

package "libcurl3"
package "libcurl3-gnutls"
package "libcurl4-gnutls-dev"
package "libcurl4-openssl-dev"
package "libv8-dev"

gem_package "bundler"
gem_package "rake"
gem_package "ruby-shadow"
gem_package "astrails-safe"