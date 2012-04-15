require "set"
require "rake/task"
require "migrake/dsl"
require "migrake/version"

module Migrake
  class << self
    # Public: Get/Set the store where Migrake checks for which tasks shouldn't
    # be run. This should implement Migrake::FileSystemStore's interface.
    attr_accessor :store
  end

  # Public: Run all the rake tasks in `set` that haven't been stored in
  # `store`.
  #
  # set   - A Set with tasks to be run.
  # store - A Store (such as Migrake::FileSystemStore), to know which tasks
  #         have already been run.
  #
  # Returns the Set of tasks that were run.
  def self.run(set, store)
    (set - store.all).each do |task|
      Rake::Task[task].invoke
      store.put(task)
    end
  end
end

# The FileSystemStore is the default store.
require "migrake/file_system_store"
