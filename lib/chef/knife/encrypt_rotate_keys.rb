# Description: Chef-Vault EncryptRotateSecret class
# Copyright 2013, Nordstrom, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/knife'
require 'chef-vault'

class EncryptRotateKeys < Chef::Knife
  deps do
    require 'chef/search/query'
    require File.expand_path('../mixin/compat', __FILE__)
    require File.expand_path('../mixin/helper', __FILE__)
    include ChefVault::Mixin::KnifeCompat
    include ChefVault::Mixin::Helper
  end

  banner "knife rotate secret [VAULT] [ITEM] --mode MODE"

  option :mode,
    :short => '-M MODE',
    :long => '--mode MODE',
    :description => 'Chef mode to run in default - solo'

  def run
    vault = @name_args[0]
    item = @name_args[1]

    if vault && item
      set_mode(config[:mode])

      begin
        item = ChefVault::Item.load(vault, item)
        item.rotate_keys!
      rescue ChefVault::Exceptions::KeysNotFound,
             ChefVault::Exceptions::ItemNotFound

        raise ChefVault::Exceptions::ItemNotFound,
              "#{vault}/#{item} does not exists, "\
              "use 'knife encrypt create' to create."
      end
    else
      show_usage
    end
  end

  def show_usage
    super
    exit 1
  end
end
  