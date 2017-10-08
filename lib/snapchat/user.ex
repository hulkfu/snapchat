defmodule Snapchat.User do
  @moduledoc """
  每个在线的用户对应一个 user 进程。用户下线，这个进程则停止。
  ws_pid 负责将内容显示到 web 上
  matcher_pid 负责和配对的 user 通信
  """
  require Logger

  use GenServer

  defstruct ws_pid: nil, name: "", matcher_pid: nil, messages: []

  def start_link(ws_pid, name \\ "", matcher_pid \\ nil) do
    Logger.debug "New user."
    {:ok, pid} = GenServer.start_link(__MODULE__,
      %Snapchat.User{ws_pid: ws_pid, name: name, matcher_pid: matcher_pid, messages: []})
    send ws_pid, {:message, "new_online"}
    Snapchat.Matcher.new_user pid
    pid
  end

  def get_message(pid) do
    GenServer.call pid, :get_message
  end

  def new_message(pid, message) do
    GenServer.cast pid, {:new_message, message}
  end

  def set_matcher(pid, matcher_pid) do
    GenServer.cast pid, {:set_matcher, matcher_pid}
    GenServer.cast matcher_pid, {:set_matcher, pid}
  end

  # def init(ws_pid, name, matcher_pid) do
  #   {:ok, %Snapchat.User{ws_pid: ws_pid, name: name, matcher_pid: matcher_pid, messages: []}}
  # end

  def handle_call(:get_message, _from, user) do
    Logger.info "get_message: " <> inspect(user)
    {new_message, last_messages} = List.pop_at user.messages, 0
    {:reply, new_message, %{user | messages: last_messages}}
  end

  def handle_cast({:new_message, message}, user) do
    {:noreply, %{user | messages: [message] ++ user.messages}}
  end

  def handle_cast({:set_matcher, matcher_pid}, user) do
    Logger.debug "set_matcher for " <> inspect(matcher_pid)
    send user.ws_pid, {:status, "matched"}
    {:noreply, %{user | matcher_pid: matcher_pid}}
  end
end
