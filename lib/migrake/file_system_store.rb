require "yaml"
require "pathname"
require "fileutils"

# The FileSystemStore handles the file where tasks that have already been run
# are stored so they aren't run again.
class Migrake::FileSystemStore
  # Public: Initialize the store.
  #
  # path - The path to the file where we store the information. A Pathname of
  #        String should be provided.
  def initialize(path)
    @path = Pathname(path)
  end

  # Public: Ensure the file we use to store information exists.
  #
  # Returns nothing.
  def prepare
    FileUtils.mkdir_p @path.dirname
    FileUtils.touch @path
  end

  # Public: Add one task to the store. This immediately writes the file to
  # disk, to preserve consistency.
  #
  # task - A string with a task's name.
  #
  # Returns nothing.
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
  # Returns nothing.
  def write(set)
    @path.open("w+") { |f| f.puts YAML.dump(set) }
  end
end

# Automagic configuration. If this environment has a MIGRAKE_STATUS_DIR, use it
# for the MIGRAKE_STATUS file. If not, default to the current directory.
Migrake.store = Migrake::FileSystemStore.new(
  Pathname(ENV.fetch("MIGRAKE_STATUS_DIR", Dir.pwd)).join("MIGRAKE_STATUS")
)
