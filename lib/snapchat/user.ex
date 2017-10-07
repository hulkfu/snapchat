defmodule Snapchat.User do
  use GenServer

  defstruct name: "", matcher_pid: nil, messages: []

  def start_link(name, matcher_pid) do
    {:ok, pid} = GenServer.start_link(__MODULE__,
      %Snapchat.User{name: name, matcher_pid: matcher_pid, messages: []})
    pid
  end

  def get_message(pid) do
    GenServer.call pid, :get_message
  end

  def new_message(pid, message) do
    GenServer.cast pid, {:new_message, message}
  end

  def init(name, matcher_pid) do
    {:ok, %Snapchat.User{name: name, matcher_pid: matcher_pid, messages: []}}
  end

  def handle_call(:get_message, _from, user) do
    IO.puts inspect(user)
    {new_message, last_messages} = List.pop_at user.messages, 0
    {:reply, new_message, %{user | messages: last_messages}}
  end

  def handle_cast({:new_message, message}, user) do
    {:noreply, %{user | messages: [message] ++ user.messages}}
  end

  def handle_cast({:set_matcher, matcher_pid}, user) do
    {:noreply, %{user | matcher_pid: matcher_pid}}
  end
end
