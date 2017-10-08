defmodule Snapchat.Matcher do
  require Logger
  use GenServer

  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    pid
  end

  # def init(users) do
  #   {:ok, users}
  # end

  def new_user(user_pid) do
    Logger.debug "matcher new user " <> inspect(user_pid)
    GenServer.cast __MODULE__, {:new_user, user_pid}
  end

  # can match
  def handle_cast({:new_user, user_pid}, users) do
    Logger.debug "Matcher users: " <> inspect(users)
    if rem(length(users), 2) == 1 do
      {pre_user_pid, last_users} = List.pop_at users, -1
      Snapchat.User.set_matcher pre_user_pid, user_pid
      {:noreply, last_users}
    else
      Logger.debug "Matcher add new user_pid: " <> inspect(user_pid)
      {:noreply, List.insert_at(users, 0, user_pid)}
    end

  end

end
