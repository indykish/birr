class Megam
  class DudeOptions
    def self.setter(*method_names)
       method_names.each do |name|
        send :define_method, name do |data|
          instance_variable_set "@#{name}".to_sym, data
        end
      end
    end

    def self.varargs_setter(*method_names)
      method_names.each do |name|
        send :define_method, name do |*data|
          instance_variable_set "@#{name}".to_sym, data
        end
      end
    end

    setter :sudo, :start_time, :tarball
    varargs_setter :directory, :command
    attr_reader :commands

    def initialize(&block)
      # defaults
      @tarball         = nil
      @sudo            = false
      @directory       = []
      @command         = []
      @commands        = [] 
      @start_time      = Time.now
      instance_eval(&block)

    end
    
    def commands
      @commands = @command.flatten if @command
    end
    
    def sudo?
    @sudo
    end
    
    def tarball_file
      @tarball_file ||= @tarball
    end

    def to_s
      tmps = ""
      tmps << "sudo :" + @sudo.to_s + "\n"
      tmps << "dir  :" + @directory.to_s + "\n"
      tmps << "cmd  :" + commands.to_s + "\n"
      tmps << "strt :" + @start_time.to_s
    end
  end
end
