require "rake/task"
require "migrake/dsl"
require "yaml"
require "set"
require "pathname"

module Migrake
  # Public: Change the directory where we keep the MIGRAKE_STATUS file.
  #
  # dir - A filesystem path.
  #
  # Returns the directory path.
  def self.status_file_directory=(dir)
    @status_dir = Pathname(dir)
  end

  # Public: Get the directory where we keep the MIGRAKE_STATUS file. If no
  # directory is set, we will try to fetch it from the ENV, using the
  # MIGRAKE_STATUS_DIR environment variable. If that isn't set either, we
  # default to the working directory.
  #
  # Returns a Pathname.
  def self.status_file_directory
    @status_dir ||= Pathname(ENV.fetch("MIGRAKE_STATUS_DIR", Dir.pwd))
  end

  # The Runner is responsible for selecting the rake tasks to be run and run
  # them, unless they have already been run in this host.
  module Runner
    # Public: Run all the rake tasks in `set` that haven't been stored in
    # `store`.
    #
    # set   - A Set with tasks to be run.
    # store - A Migrake::Store with the tasks that have already been run.
    #
    # Returns the Set of tasks that were run.
    def self.run(set, store)
      (set - store.all).each do |task|
        Rake::Task[task].invoke
        store.put(task)
      end
    end
  end

  # The Store handles the file where tasks that have already been run are stored
  # so they aren't run again.
  class Store
    # Public: Initialize the store.
    #
    # path - The path to the file where we store the information.
    def initialize(path)
      @path = path
    end

    # Public: Add one task to the store. This immediately writes the file to
    # disk, to preserve consistency.
    #
    # task - A string with a task's name.
    #
    # Returns nil.
    def put(task)
      write(all << task)
    end

    # Public: Load all the tasks from the store.
    #
    # Returns a Set.
    def all
      @all ||= YAML.load(@path.read) || Set.new
    end

    # Public: Write a whole set of tasks to the store, replacing what is in it.
    #
    # set - A Set of tasks.
    #
    # Returns nil.
    def write(set)
      @path.open("w+") { |f| f.puts YAML.dump(set) }
    end
  end
end
