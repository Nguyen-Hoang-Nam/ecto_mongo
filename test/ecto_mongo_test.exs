defmodule EctoMongoTest do
  use ExUnit.Case
  doctest EctoMongo

  test "greets the world" do
    assert EctoMongo.hello() == :world
  end
end
