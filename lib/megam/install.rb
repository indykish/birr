require "mixlib/shellout"
require "megam/dude_options"
require "megam/core/text"
require "megam/dude"
require "megam/workarea"
require "megam/transferarea"
require "megam/cmd_verb"
require "ruby-progressbar"

class Megam
  module Install

    Dude.text.info(Dude.text.color("            |***|", :yellow, :bold))
    Dude.text.info(Dude.text.color("      Dude  |* *| "+::Megam::VERSION, :red))
    Dude.text.info(Dude.text.color("            |===|", :green, :bold))
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
          dude_opts = DudeOptions.new(&block)
          options[:method_name] = __method__.to_s
          copy(options,dude_opts)
        end
      end

      def script(options = {},&block)
        if block_given?          
          dude_opts = DudeOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = "package"
          key =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory))]
          dude_opts.command(cmd.find_package_script(options[:method_name]+'.'+cmd.directory, dude_opts.commands).fetch(key))
          shelly(options,dude_opts)
        end
      end

      def install(options = {},&block)
        if block_given?
          dude_opts = DudeOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = __method__.to_s
          shelly(options,dude_opts)
        end
      end

      def tarball(options = {},&block)
        if block_given?
          dude_opts = DudeOptions.new(&block)
          cmd = Megam::WorkArea.new(options)
          options[:method_name] = __method__.to_s
          tar_dir =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory.gsub(".", File::SEPARATOR)))]

          tmp_opts = {:tar_file => File.join(tar_dir,dude_opts.tarball_file), :to_dir =>  Megam::TransferArea.convert_to_transferarea_dir(cmd.directory) }
          dude_opts.command(Megam::CmdVerb.untar(tmp_opts))
          shelly(options, dude_opts)
        end
      end

      #now run the stuff in parsed block.
      #eg.pull out the directory and copy it.
      def copy (options, dude_opts)
        cmd = Megam::WorkArea.new(options)

        Dude.text.info(Dude.text.color("DUMP :", :green, :bold) + "dumping directory " + "#{cmd.directory}")

        if cmd.directory_avail?
          from_dir =  Megam::Install.workarea_loader[(File.join(options[:method_name],cmd.directory))]
          to_dir = Megam::TransferArea.convert_to_transferarea_dir(cmd.directory)

          goahead_copy = Dude.text.agree("Do you wish to copy files from #{from_dir}\n to #{to_dir} [y/n]?")

          if Dir.exists?(from_dir) && goahead_copy
            progress_bar =  ProgressBar.create(:title => "Files", :starting_at => 0)
            cmd.list_directory(from_dir)
            progress_bar.progress = 50
            Dude.text.info(Dude.text.color("file :", :blue) + "copying [" + cmd.dir_glob_files.size.to_s + "] files.." )
            #formulate the shell cp command, and returns it. now feed it to shelly and execute it.
            cp_opts = { :from_dir => from_dir,
            :to_dir => to_dir,
            :sudo => dude_opts.sudo?,
            :recursive => true,
            :copy_on_new => true}
            dude_opts.command(Megam::CmdVerb.cp(cp_opts))
            options[:message] = ''
            shelly(options,dude_opts)
            sleep 1
          progress_bar.finish

          else
            Dude.text.warn "Skip : You need to specify the :directory to your dump command before you can use it"
          end
        end
      end

      #now run the stuff in parsed block.
      #eg.pull out the command and run it.
      def shelly (options ={},dude_opts)
        msg = ''
        msg            = options[:message] if options[:message]
        Dude.text.info(Dude.text.color("INSTALL :", :green, :bold) + msg.to_s) unless !msg
        command ||= dude_opts.commands
        unless !DudeOptions.method_defined?(:command)
          command.each do |scmd|
            Dude.text.info(Dude.text.color("SHELL   :", :cyan, :bold) + scmd.to_s)
            find = Mixlib::ShellOut.new(scmd.strip)
            find.run_command
            Dude.text.info find.stdout
            find.error!
          end
        end
      end
    end

  end
end
