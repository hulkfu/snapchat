defmodule UserTest do
  use ExUnit.Case
  doctest Snapchat.User

  test "user send and get message" do
    u1 = Snapchat.User.start_link "u1"
    Snapchat.User.new_message u1, "new message"
    msg = Snapchat.User.get_message u1
    assert msg == "new message"
  end
end
