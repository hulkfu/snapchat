defmodule SnapchatTest do
  use ExUnit.Case
  doctest Snapchat

  test "greets the world" do
    assert Snapchat.hello() == :world
  end
end
