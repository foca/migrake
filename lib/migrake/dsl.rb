require "migrake"

module Migrake
  module DSL
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
