defmodule Snapchat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Snapchat.Worker.start_link(arg)
      # {Snapchat.Worker, arg},
      Plug.Adapters.Cowboy.child_spec(:http, Snapchat.Router, [],
        [port: 4000, dispatch: dispatch])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Snapchat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_, [
        {"/ws", Snapchat.SocketHandler, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Snapchat.Router, []}}
        ]}
      ]
  end
end
