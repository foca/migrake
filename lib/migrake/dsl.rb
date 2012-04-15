module Migrake
  module DSL
    # Public: Define the rake tasks required to run migrake. This defines the
    # following tasks:
    #
    #   - A task to ensure we can use whatever is defined as `Migrake.store`.
    #   - A `migrake:ready` task to bootstrap new environments by writing all
    #     the tasks to the store.
    #   - The `migrake` task, that will run any tasks not run before.
    #
    # tasks - A Set of tasks to be run.
    #
    # Returns nothing.
    def migrake(tasks)
      namespace :migrake do
        task :check_store do
          Migrake.store.prepare
        end

        desc "Tell migrake that all defined tasks have already been run"
        task ready: :check_store do
          Migrake.store.write(tasks)
        end
      end

      desc "Run the tasks defined by migrake"
      task migrake: "migrake:check_store" do
        Migrake.run(tasks, Migrake.store)
      end
    end
  end
end

extend Migrake::DSL
