defmodule PijiTest do
  use ExUnit.Case
  doctest Piji

  test "greets the world" do
    assert Piji.hello() == :world
  end
end
