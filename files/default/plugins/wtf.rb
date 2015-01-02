#
# Author:: Joan Touzet (<joant@cloudant.com>)
# Copyright:: Copyright (c) 2012 Cloudant, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'
require 'net/http'

Ohai.plugin(:WTF) do
  provides "wtf"

  collect_data do
    url = 'http://ip.aufnahme.com'
    begin
      response = Net::HTTP.get(URI.parse(url))
      results = JSON.parse(response)

      if not results.nil?
        wtf Mash.new
        if not results['ip'].nil?
          wtf['public_ipv4'] = results['ip']
        end
      end

    rescue
      Ohai::Log.debug("myip lookup failed.")
    end
  end

end
