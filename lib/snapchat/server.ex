defmodule Snapchat.Server do
  use GenServer

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    pid
  end

end
