require 'hashie'

class Megam
  class WorkAreaLoader

    attr_reader :workarea_preconfig # a hash the preconfig mapping eg: you => ~/megam_install/you
    attr_reader :workarea_by_name   # a Mash, indexed on name.
    attr_reader :workarea_paths
 include Enumerable
    
    def initialize(*workarea_repo_paths)
      workarea_repo_paths = workarea_repo_paths.flatten
      raise ArgumentError, "You must specify at least one workarea repo path" if workarea_repo_paths.empty?
      @workarea_by_name = Hashie::Mash.new
      @workarea_paths = Hash.new {|h,k| h[k] = []}
      @workarea_preconfig = Hash.new {|h,k| h[k] = []}
      @transferarea_paths = Hash.new {|h,k| h[k] = []}

      @workarea_repo_paths = workarea_repo_paths.map do |val|
        temp_val = File.join(Megam::WorkArea.workarea_install_directory,val)
         @workarea_preconfig[val] = temp_val
         val = temp_val
      end
      load_workarea_repos
    end

    def load_workarea_repos
      @workarea_repo_paths.each do |repo_path|
        Dir[File.join(repo_path, "*")].each do |first_level_path|
          load_workarea_repo(File.basename(first_level_path), [repo_path])        
        Dir[File.join(first_level_path, "*")].each do |work_repo_path|
          next unless File.directory?(work_repo_path)
          load_workarea_repo(File.basename(work_repo_path), [first_level_path])
        end
      end 
      end
      @workarea_by_name
    end
    
    def load_workarea_repo(work_repo_name, repo_paths=nil)
      repo_paths ||= @workarea_repo_paths
      work_repo_key = nil

      repo_paths.each do |repo_path|
        workarea_repo = File.join(repo_path, work_repo_name.to_s)
        next unless File.directory?(workarea_repo) and Dir[File.join(repo_path, "**")].include?(workarea_repo)
        work_repo_key = workarea_repo.dup.gsub(Megam::WorkArea.workarea_install_directory + File::SEPARATOR ,"") #remove the extra slash
        @workarea_paths[work_repo_key] << workarea_repo
        @workarea_by_name[work_repo_key] = workarea_repo
      end
      @workarea_by_name[work_repo_key]
    end
    
    
    def [](workarea)
      if @workarea_by_name.has_key?(workarea.to_sym) or load_workarea_repo(workarea.to_sym)
      @workarea_by_name[workarea.to_sym]
      else
        raise Exceptions::WorkAreaNotFound, "Cannot find a workarea named #{workarea.to_s}; did you forget to add it in WORKAREA_INSTALL_DIR variable ?"
      end
    end

    alias :fetch :[]

    def has_key?(workarea_name)
      not self[workarea_name.to_sym].nil?
    end

    alias :key? :has_key?

    def each
      @workarea_by_name.keys.sort { |a,b| a.to_s <=> b.to_s }.each do |cname|
        yield(cname, @workarea_by_name[cname])
      end
    end

    def workarea_names
      @workarea_by_name.keys.sort
    end

  end
end
