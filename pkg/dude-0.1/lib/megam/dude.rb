#
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

require 'pp'
require 'megam/core/text'

class Megam::Dude

  attr_accessor :text
  attr_accessor :config
  #text is used to print stuff in the terminal (message, log, info, warn etc.)
  def self.text
    @text ||= Megam::Text.new(STDOUT, STDERR, STDIN, {})
  end

  # I don't think we need this method. Will remove it later.
  # We need to just call text.msg
  def self.msg(msg="")
    text.msg(msg)
  end

  # Create a new instance of the current class configured for the given
  # arguments and options
  def initialize()
  end

  # Run dude for the given +args+ (ARGV), adding +options+ to the list of
  # CLI options that the subcommand knows how to handle.
  # ===Arguments
  # args::: usually ARGV
  # options::: A Mixlib::CLI option parser hash. These +options+ are how
  # subcommands know about global dude CLI options
  def run(args=[], config={})
    @config = config.dup
    @text ||= Megam::Text.new(STDOUT, STDERR, STDIN, config)
    # configure your dude.
    configure_dude

  end

  # configure meggy, to startwith locate the config file under .meggy/dude.rb
  # Once located, read the dude.rb config file. parse them, and report any ruby syntax errors.
  # if not merge then inside Meggy::Config object.
  def configure_dude
    unless config[:install_file]
      locate_install_file
    end
    # Don't try to load a dude.rb if it doesn't exist.
    if config[:install_file]
      Megam::Log.debug("Using configuration from #{config[:install_file]}")
      apply_computed_config
      read_config_file(config[:install_file])
    else
      text.warn("No dude configuration file found")
    end

  end

  def locate_install_file
    # Look for $HOME/.meggy/dude.rb
    if ENV['HOME']
      user_config_file =  File.expand_path(File.join(ENV['HOME'], '.meggy', 'install.rb'))
    end

    if File.exist?(user_config_file)
      config[:install_file] = user_config_file
    end
  end

  # Catch-all method that does any massaging needed for various config
  # components, such as expanding file paths and converting verbosity level
  # into log level.
  def apply_computed_config
  
    case config[:verbosity]
    when 0, nil
      config[:log_level] = :error
    when 1
      config[:log_level] = :info
    else
    config[:log_level] = :debug
    end

    Mixlib::Log::Formatter.show_time = false
    Megam::Log.init(config[:log_location] || STDOUT)
    Megam::Log.level(config[:log_level] || :error)
    
    config.each do |key, val| 
      Megam::Config[key] = val
    end
    
  end

  # reads all the config from the .meggy/dude.rb and stores it inside Meggy::Config
  def read_config_file(file)
    self.instance_eval(IO.read(file), file, 1)
  rescue SyntaxError => e
    @text.error "You have invalid ruby syntax in your config file #{file}"
    @text.info(text.color(e.message, :red))
    if file_line = e.message[/#{Regexp.escape(file)}:[\d]+/]
      line = file_line[/:([\d]+)$/, 1].to_i
      highlight_config_error(file, line)
    end
    exit 1
  rescue Exception => e
    @text.error "You have an error in your config file #{file}"
    @text.info "#{e.class.name}: #{e.message}"
    filtered_trace = e.backtrace.grep(/#{Regexp.escape(file)}/)
    filtered_trace.each {|line| text.msg(" " + text.color(line, :red))}
    if !filtered_trace.empty?
      line_nr = filtered_trace.first[/#{Regexp.escape(file)}:([\d]+)/, 1]
      highlight_config_error(file, line_nr.to_i)
    end

    exit 1
    end

  #ERROR: You have invalid ruby syntax in your config file /home/ram/.meggy/dude.rb
  #/home/ram/.meggy/dude.rb:9: syntax error, unexpected '='
  #dude[:username] > = "admin"
  #                  ^
  # # /home/ram/.meggy/dude.rb
  #  8: meggy_server_url          'http://localhost:6167'
  #  9: dude[:username] > = "admin"
  # 10: dude[:password] = "team4dog"
  # Line 9 is marked in red, and the 3rd line where the error is show is highlighted in red.
  #This is in case of a ruby parse error.
  def highlight_config_error(file, line)
    config_file_lines = []

    # A file line is split into the line number (index) and the line content.
    # The line number is converted to string (to_s), right justified 3 characters with a colon, and its trimmed (chomp)

    IO.readlines(file).each_with_index {|l, i| config_file_lines << "#{(i + 1).to_s.rjust(3)}: #{l.chomp}"}
    # mark the appropriate line with a red color, if its just one line, then mark the zeroth line.
    # if not get the range (deducting 2), and mark the second line.
    if line == 1
      lines = config_file_lines[0..3]
      lines[0] = text.color(lines[0], :red)
    else
      lines = config_file_lines[Range.new(line - 2, line)]
      lines[1] = text.color(lines[1], :red)
    end
    text.msg ""
    # print the name of the file in white
    text.msg text.color(" # #{file}", :white)
    # print the rest of the line.
    lines.each {|l| text.msg(l)}
    text.msg ""
  end

   

  private

  def self.working_directory
    ENV['PWD'] || Dir.pwd
  end

end
