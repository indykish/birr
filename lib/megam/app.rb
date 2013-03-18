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

require 'pp'
require 'megam/config'
require 'megam/birr'
require 'mixlib/cli'
require 'tmpdir'
require 'rbconfig'

class Megam::App
  include Mixlib::CLI
  #include(a_module) is called inside a class, and adds module methods as instance methods.
  #extend(a_module) adds all module methods to the instance it is called on.

  NO_COMMAND_GIVEN = "You need to pass a command with option (e.g., birr -i <install_path>)\n"

  banner "Usage: birr (options)"

  option :install_file,
    :short => "-i INSTALL",
    :long => "--install INSTALL",
    :required => true,
    :description => "The installation file path to use",
    :proc => lambda { |path| File.expand_path(path, Dir.pwd) }

  verbosity_level = 0
  option :verbosity,
    :short => '-V',
    :long => '--verbose',
    :description => "More verbose output. Use twice for max verbosity",
    :proc => Proc.new { verbosity_level += 1},
    :default => 0

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0

  option :yes,
    :short => "-y",
    :long => "--yes",
    :description => "Say yes to all prompts for confirmation"

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show birr version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Birr: #{::Megam::VERSION}"},
    :exit         => 0

  #attr_accessors are setters/getters in ruby.  The arguments are filtered and available for use
  #to subclasses.
  attr_accessor :name_args

  attr_accessor :text
  def initialize
    super # The super calls the mixlib cli.

    ##Traps are being set for the following when an application starts.
    ##SIGHUP        1       Term    Hangup detected on controlling terminal
    ##                             or death of controlling process
    ##SIGINT        2       Term    Interrupt from keyboard
    ##SIGQUIT       3       Core    Quit from keyboard
    trap("TERM") do
      Megam::App.fatal!("SIGTERM received, stopping", 1)
    end

    trap("INT") do
      Megam::App.fatal!("SIGINT received, stopping", 2)
    end

    trap("QUIT") do
      Megam::Log.info("SIGQUIT received, call stack:\n  " + caller.join("\n  "))
    end

    @text ||= Megam::Text.new(STDOUT, STDERR, STDIN, {})

  end

  # Run the "birr app". Let it roam and stay by our side.[Go birr..Does it remind of the Hutch adv.].
  # The first thing run does is it parses the options. Once the first level of parsing is done,
  # ie the help, no_command, sub_command entry is verified it proceeds to call
  # Megam_Birr with the user entered options and arguments (ARGV)
  def run
    Mixlib::Log::Formatter.show_time = false
    validate_and_parse_options
    Megam::Birr.new.run(@named_args, config)
    exit 0
  end

  def parse_options(args)
    super
  rescue OptionParser::InvalidOption => e
    puts "Error: " + e.to_s
    puts self.opt_parser
    exit(1)
    end

  ##A few private helper methods being used by app itself.
  ##If you run an application for ever, you might pool all the executions and gather the stacktrace.
  private

  # A check is performed to see if an option is entered, help or version
  def validate_and_parse_options
    # Checking ARGV validity *before* parse_options because parse_options
    # mangles ARGV in some situations
    if no_command_given?
      print_help_and_exit(1, NO_COMMAND_GIVEN)
    elsif (want_help? || want_version?)
      print_help_and_exit
    else
      @named_args = parse_options(ARGV)
    end

  end

  def no_subcommand_given?
    ARGV[0] =~ /^-/
  end

  def no_command_given?
    ARGV.empty?
  end

  def want_help?
    ARGV[0] =~ /^(--help|-h)$/
  end

  def want_version?
    ARGV[0] =~ /^(--version|-v)$/
  end

  # Print the help message with the exit code.  If no command is given, then a fatal message is printed.
  # The options are parsed by calling the parse_options present in the mixlib cli as extended by the app.
  # A error gets caught and results in an ugly stack trace, which probably needs to be shown in an elegant way.
  # The stacK should be logged using the debug_stacktrace method in the app class.
  def print_help_and_exit(exitcode=1, fatal_message=nil)
    Megam::Log.error(fatal_message) if fatal_message
    parse_options(ARGV)
    exit exitcode
  end

  class << self
    #The exception in ruby carries the class, message and the trace.
    #http://www.ruby-doc.org/core-2.0/Exception.html
    def debug_stacktrace(e)
      message = "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
      megam_stacktrace_out = "Generated at #{Time.now.to_s}\n"
      megam_stacktrace_out += message

      #after the message is formulated in the variable megam_stack_trace_out, its
      #stored in a file named megam-stacktrace.out
      Megam::FileCache.store("megam-stacktrace.out", megam_stacktrace_out)

      ##The same error is logged in the log file saying, go look at megam-stacktrace.out for error.
      Megam::Log.fatal("Stacktrace dumped to #{Megam::FileCache.load("megam-stacktrace.out", false)}")
      Megam::Log.debug(message)
      true
    end

    # Log a fatal error message to both STDERR and the Logger, exit the application
    def fatal!(msg, err = -1)
      Megam::Log.fatal(msg)
      Process.exit err
    end

    def exit!(msg, err = -1)
      Megam::Log.debug(msg)
      Process.exit err
    end
  end
end
