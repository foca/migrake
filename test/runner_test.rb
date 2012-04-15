require_relative "test_helper"
require "rake"

describe Migrake::Runner do
  it "runs tasks that aren't in the store" do
    define_tasks "a", "b", "c"
    define_store "a"

    expect_tasks_ran "b", "c"

    Migrake::Runner.run(Set.new(["a", "b", "c"]), store)

    store.verify
  end

  it "runs no tasks if all the tasks are in the store" do
    define_tasks "a", "b", "c"
    define_store "a", "b", "c"
    # setting no expectation for tasks run passes only if no tasks are run

    Migrake::Runner.run(Set.new(["a", "b", "c"]), store)

    store.verify
  end

  it "doesn't mind stored tasks that don't exist anymore" do
    define_tasks "a"
    define_store "b", "c"

    expect_tasks_ran "a"

    Migrake::Runner.run(Set.new(["a", "b", "c"]), store)

    store.verify
  end

  def store
    @store ||= MiniTest::Mock.new
  end

  def define_store(*tasks)
    store.expect :all, Set.new(tasks)
  end

  def define_tasks(*tasks)
    tasks.each { |task| Rake::Task.define_task(task) }
  end

  def expect_tasks_ran(*tasks)
    Set.new(tasks).each do |task|
      store.expect :put, nil, [task]
    end
  end
end
