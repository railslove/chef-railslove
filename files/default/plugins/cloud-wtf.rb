#
# Author:: Cary Penniman (<cary@rightscale.com>)
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

Ohai.plugin(:CloudWTF) do
  provides "cloud"
  depends "wtf"
  depends "gce"

  def on_gce?
    gce != nil
  end

  collect_data do
    unless on_gce?
      cloud Mash.new

      cloud[:public_ips] = Array.new
      cloud[:private_ips] = Array.new
      cloud[:public_ipv4] = wtf['public_ipv4']
      cloud[:public_ipv4] = wtf['public_ipv4']
      cloud[:local_ipv4]  = ipaddress
      cloud[:provider] = "wtf"
    end
  end
end
