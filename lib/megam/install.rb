require "mixlib/shellout"
require "megam/birr_options"
require "megam/core/text"
require "megam/birr"
require "megam/workarea"
require "megam/transferarea"
require "megam/cmd_verb"
require "ruby-progressbar"

class Megam
  module Install

    Birr.text.info(Birr.text.color("            |***|", :yellow, :bold))
    Birr.text.info(Birr.text.color("      Birr  |* *| "+::Megam::VERSION, :red))
    Birr.text.info(Birr.text.color("            |===|", :green, :bold))
    def self.included(receiver)
      receiver.extend(Megam::Install::ClassMethods)
    end

    WORKAREA_PRECONFIG_DIRS = %w[package dump tarball]

    def self.workarea_loader
      @workarea_loader ||= Megam::WorkAreaLoader.new(WORKAREA_PRECONFIG_DIRS)
    end

    module ClassMethods
      #default parms del_if_exists is false
      #message prints a dump directory string
      def dump(options = {},&block)
        if block_given?
          birr_opts = BirrOptions.new(&block)
          options[:method_name] = __method__.to_s
          copy(options,birr_opts)
        end
      end

      def script(options = {},&block)
        if block_given?
          birr_opts = BirrOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = "package"
          key =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory))]
          birr_opts.command(cmd.find_package_script(options[:method_name]+'.'+cmd.directory, birr_opts.commands).fetch(key))
          shelly(options,birr_opts)
        end
      end

      def install(options = {},&block)
        if block_given?
          birr_opts = BirrOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = __method__.to_s
          shelly(options,birr_opts)
        end
      end

      def tarball(options = {},&block)
        if block_given?
          birr_opts = BirrOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = __method__.to_s
          tar_dir =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory.gsub(".", File::SEPARATOR)))]

          tmp_opts = {:tar_file => File.join(tar_dir,birr_opts.tarball_file), :to_dir =>  Megam::TransferArea.convert_to_transferarea_dir(cmd.directory) }
          birr_opts.command(Megam::CmdVerb.untar(tmp_opts))
          shelly(options, birr_opts)
        end
      end

      #now run the stuff in parsed block.
      #eg.pull out the directory and copy it.
      def copy (options, birr_opts)
        cmd = Megam::WorkArea.new(options)

        Birr.text.info(Birr.text.color("DUMP :", :green, :bold) + "dumping directory " + "#{cmd.directory}")

        if cmd.directory_avail?
          from_dir =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory))]
          to_dir = Megam::TransferArea.convert_to_transferarea_dir(cmd.directory)

          goahead_copy = Birr.text.agree("Do you wish to copy files from #{from_dir}\n to #{to_dir} [y/n]?")

          if Dir.exists?(from_dir) && goahead_copy
            #formulate the shell cp command, and returns it. now feed it to shelly and execute it.
            cp_opts = { :from_dir => from_dir,
              :to_dir => to_dir,
              :sudo => birr_opts.sudo?,
              :recursive => true,
              :copy_on_new => true}
            birr_opts.command(Megam::CmdVerb.cp(cp_opts))
            options[:message] = ''
            shelly(options,birr_opts)
          else
            unless goahead_copy
              then
              Birr.text.warn "Skip : OK."
            else
              Birr.text.fatal "Skip : You need to specify an existing #{from_dir}\n in the :directory option to dump"

            end
          end
        end
      end

      #now run the stuff in parsed block.
      #eg.pull out the command and run it.
      def shelly (options ={},birr_opts)
        msg = ''
        msg            = options[:message] if options[:message]
        Birr.text.info(Birr.text.color("INSTALL :", :green, :bold) + msg.to_s) unless !msg.strip
        command ||= birr_opts.commands
        unless !BirrOptions.method_defined?(:command)
          command.each do |scmd|
            Birr.text.info(Birr.text.color("SHELL   :", :cyan, :bold) + scmd.to_s)
            find = Mixlib::ShellOut.new(scmd.strip)
            find.run_command
            Birr.text.info find.stdout
            find.error!
          end
        end
      end
    end

  end
end
