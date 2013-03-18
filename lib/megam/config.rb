#
# License:: Apache License, Version 2.0
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

require 'megam/core/log'
require 'mixlib/config'

class Megam
  class Config
    extend(Mixlib::Config)
    def self.inspect
      configuration.inspect
    end

    def self.add_formatter(name, file_path=nil)
      formatters << [name, file_path]
    end

    def self.formatters
      @formatters ||= []
    end

    
    # Valid log_levels are:
    # * :debug
    # * :info
    # * :warn
    # * :fatal
    # These work as you'd expect. There is also a special `:auto` setting.
    # When set to :auto, Birr will auto adjust the log verbosity based on
    # context. When a tty is available (usually becase the user is running meggy
    # in a console), the log level is set to :warn, and output formatters are
    # used as the primary mode of output. When a tty is not available, the
    # logger is the primary mode of output, and the log level is set to :info
    log_level :auto
    log_location STDOUT
    # toggle info level log items that can create a lot of output
    verbose_logging true
    
    install_file nil  
    
    

  end
end
