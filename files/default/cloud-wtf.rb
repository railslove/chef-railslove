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

provides "cloud"

require_plugin "wtf"


# Make top-level cloud hashes
#
def create_objects
  cloud Mash.new
  cloud[:public_ips] = Array.new
  cloud[:private_ips] = Array.new
end

# ----------------------------------------
# wtf
# ----------------------------------------

# Is current cloud wtf?
#
# === Return
# true:: If brightbox Hash is defined
# false:: Otherwise
def on_wtf?
  wtf != nil
end

# Fill cloud hash with wtf values
def get_wtf_values
  cloud[:public_ipv4] = wtf['public_ipv4']
  cloud[:local_ipv4]  = ipaddress
  cloud[:provider] = "wtf"
end

# setup wtf cloud
if on_wtf?
  create_objects
  get_wtf_values
end

