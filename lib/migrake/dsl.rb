require "migrake"

module Migrake
  module DSL
    # Public: Define the rake tasks required to run migrake. This defines the
    # following tasks:
    #
    #   - A task to create the `Migrake.status_file_directory` unless it exists.
    #   - A task to create the MIGRAKE_STATUS file in the aforementioned
    #     directory, unless it exists.
    #   - A `migrake:ready` task to bootstrap new environments by writing all
    #     the tasks to the store.
    #   - The `migrake` task, that will run any tasks not run before.
    #
    # tasks - A Set of tasks to be run.
    #
    # Returns the `migrake` Rake::Task.
    def migrake(tasks)
      dir = Migrake.status_file_directory
      status_file = dir.join("MIGRAKE_STATUS")

      namespace :migrake do
        directory dir.to_s

        file status_file.to_s => dir.to_s do
          touch status_file
        end

        task :run_tasks => status_file.to_s do
          Migrake::Runner.run(tasks, Migrake::Store.new(status_file))
        end

        desc "Tell migrake that all defined tasks have already been run"
        task :ready => status_file.to_s do
          Migrake::Store.new(status_file).write(tasks)
        end
      end

      desc "Run the tasks defined by migrake"
      task migrake: "migrake:run_tasks"
    end
  end
end

extend Migrake::DSL
