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
require "megam/core/text"
require "megam/birr"

class Megam::CmdVerb
  
  def initialize
  end

  # cp -r -s <from directory> <to directory>
  def self.cp(opts={}) 
    cp =""
    cp << "sudo " if opts[:sudo]
    cp << "cp"
    cp << " -r " if opts[:recursive]
 #   cp << " -u " if opts[:copy_on_new] #copy  only  when  the  SOURCE file is newer than
    cp << opts[:from_dir] if opts[:from_dir] or raise Megam::Exceptions::FileNotFound
    cp << " "
    cp << opts[:to_dir] if opts[:to_dir] or raise Megam::Exceptions::FileNotFound
    cp
  end
  
  #gunzip -c foo.tar.gz | tar xvf -
  def self.untar(opts={})
    untar = "gunzip -c "
    untar << opts[:tar_file] if opts[:tar_file] 
    untar << " | tar xvf - -C "
    untar << opts[:to_dir] if opts[:to_dir]
    untar    
  end

  def to_s
    "cmdverb -> [supports cp, untar *only]"
  end
end
