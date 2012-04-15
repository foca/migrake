require_relative "test_helper"
require "tempfile"

describe Migrake::Store do
  it "can read a stored set" do
    set = Set.new(["a", "b", "c"])
    save_in_source set

    store = Migrake::Store.new(source)
    assert_equal set, store.all
  end

  it "an empty file means an empty set" do
    store = Migrake::Store.new(source)
    assert_equal Set.new, store.all
  end

  it "can add an entry to the store" do
    store = Migrake::Store.new(source)
    store.put("test")

    assert_equal Set.new(["test"]), store.all
  end

  it "can write a set replacing whatever is there on the file" do
    save_in_source Set.new(["d", "e", "f", "g"])

    store = Migrake::Store.new(source)
    store.write Set.new(["a", "b", "c"])

    assert_equal Set.new(["a", "b", "c"]), store.all
  end

  after do
    source.unlink # just to be polite
  end

  def save_in_source(set)
    source.open("w+") { |f| f.puts YAML.dump(set) }
  end

  def source
    @source ||= Pathname(Tempfile.new("store").path)
  end
end
