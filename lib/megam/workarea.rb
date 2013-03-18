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
require "megam/dude"
require "megam/workarea_loader"

class Megam::WorkArea

  attr_accessor :del_if_exists
  attr_accessor :directory
  attr_accessor :msg
  attr_accessor :dir_glob_files
  def initialize (options)
    @del_if_exists = false
    @directory      = options[:directory] if options[:directory]
    @del_if_exists  = options[:del_if_exists] if options[:del_if_exists]
    @msg            = options[:message] if options[:message]
  end

  def directory_avail?
    directory
  end

  #Lists all the files under the workarea_installer/<directory>
  #using a helper
  def list_directory(i_dir)
    @dir_glob_files = {}
    @dir_glob_files ||= (find_files_via_dirglob(i_dir).values).flatten
  end

  #Lists all the files under the dir
  def find_files_via_dirglob(i_dir)
    dir_files = {}
    Megam::Dude.text.info(Megam::Dude.text.color("GLOB :", :green, :bold) + "#{i_dir}")
    if Dir.exists?(i_dir)
      dir_files[i_dir] = Dir.glob("#{i_dir}/**/*")
    end
    dir_files
  end

  def self.workarea_install_directory
    File.dirname(Megam::Config[:install_file])
  end

  def workarea_install(i_dir)
    unless workarea_install_not_found!(i_dir)
      File.join(workarea_install_directory,i_dir)
    end
  end

  # :nodoc:
  # Error out and print usage. probably becuase the arguments given by the
  # user could not be resolved to a subcommand.
  def workarea_install_not_found!(i_dir)
    missing_install_dir = nil

    if missing_install_dir = !(WORKAREA_PRECONFIG_DIRS.find {|wai| wai == i_dir} )
      Megam::Dude.text.fatal("Cannot find workarea install dir  for: '#{i_dir}'")
      exit 10
    end
    missing_install_dir
  end

  def find_package_script(dir,package_words)
    adir = dir.dup
    adir = adir.gsub(".", File.path("/"))
    package_script_files = {}
    matching_dir = nil

    while ( package_script_files.empty? ) && ( !package_words.empty? )
      if (!matching_dir) && (!package_words.empty?)
        package_script ||= package_words.pop
        matching_dir ||= Megam::Install.workarea_loader[File.join(adir.strip)]
        package_script_files[matching_dir] = Dir.glob("#{matching_dir}/**"+ package_script)
      end
    end
    package_script_files
  end

  def to_s
    "workarea[:directory =>"+directory+"]"
  end
end