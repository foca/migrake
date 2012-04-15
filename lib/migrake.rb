require "rake/task"
require "migrake/dsl"
require "yaml"
require "set"
require "pathname"

module Migrake
  def self.status_file_directory=(dir)
    @status_dir = Pathname(dir)
  end

  def self.status_file_directory
    @status_dir ||= Pathname(ENV.fetch("MIGRAKE_STATUS_DIR", Dir.pwd))
  end

  class Runner
    def self.run(set, store)
      new(set, store).run
    end

    attr :store
    attr :set

    def initialize(set, store)
      @set = set
      @store = store
    end

    def run
      set.each do |task|
        Rake::Task[task].invoke unless store.all.include?(task)
        store.put(task)
      end
    end
  end

  class Store
    def initialize(file)
      @file = file
    end

    def put(task)
      write(all << task)
    end

    def all
      @all ||= YAML.load(@file.read) || Set.new
    end

    def write(set)
      @file.open("w+") { |f| f.puts YAML.dump(set) }
    end
  end
end
