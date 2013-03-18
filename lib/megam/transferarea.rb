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

# class responsible for converting "you", "root" to the correct directories.
# This is not a good way to do so.
class Megam::TransferArea
  
  def self.convert_to_transferarea_dir(transferarea_name)
    temp_transferarea_name = transferarea_name.dup
    temp_transferarea_name = temp_transferarea_name.gsub("you", transfer_you_dir) if temp_transferarea_name.match("you")

    temp_transferarea_name = temp_transferarea_name.gsub("root", transfer_root_dir) if temp_transferarea_name.match("root")
    temp_transferarea_name = temp_transferarea_name.gsub(".", File::SEPARATOR)
    temp_transferarea_name
  end

  #the root directory. its stubbed out now to ~/Desktop/tmp/root
  def self.transfer_root_dir
    File.join(File::SEPARATOR)
  end

  #the home directory. its stubbed out now to ~/Desktop/tmp
  def self.transfer_you_dir
    File.join(ENV['HOME']) || Dir.pwd
  end

end
