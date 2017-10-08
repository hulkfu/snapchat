defmodule Snapchat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    dispatch_config = build_dispatch_config
    {:ok, _} = :cowboy.start_http(:http,
                                  100,
                                 [{:port, 4000}],
                                 [{ :env, [{:dispatch, dispatch_config}]}]
                                 )

    Snapchat.Matcher.start_link()

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Snapchat.Worker.start_link(arg)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Snapchat.Supervisor]
    Supervisor.start_link(children, opts)

  end

  def build_dispatch_config do

    # Compile takes as argument a list of tuples that represent hosts to
    # match against.So, for example if your DNS routed two different
    # hostnames to the same server, you could handle requests for those
    # names with different sets of routes. See "Compilation" in:
    #      http://ninenines.eu/docs/en/cowboy/1.0/guide/routing/
    :cowboy_router.compile([

      # :_ causes a match on all hostnames.  So, in this example we are treating
      # all hostnames the same. You'll probably only be accessing this
      # example with localhost:8080.
      { :_,

        # The following list specifies all the routes for hosts matching the
        # previous specification.  The list takes the form of tuples, each one
        # being { PathMatch, Handler, Options}
        [


          # Serve a single static file on the route "/".
          # PathMatch is "/"
          # Handler is :cowboy_static -- one of cowboy's built-in handlers.  See :
          #   http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_static/
          # Options is a tuple of { type, atom, string }.  In this case:
          #   :priv_file             -- serve a single file
          #   :cowboy_elixir_example -- application name.  This is used to search for
          #                             the path that priv/ exists in.
          #   "index.html            -- filename to serve
          {"/", :cowboy_static, {:priv_file, :snapchat, "index.html"}},

          # Serve all static files in a directory.
          # PathMatch is "/static/[...]" -- string at [...] will be used to look up the file
          # Handler is :cowboy_static -- one of cowboy's built-in handlers.  See :
          #   http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_static/
          # Options is a tuple of { type, atom, string }.  In this case:
          #   :priv_dir              -- serve files from a directory
          #   :cowboy_elixir_example -- application name.  This is used to search for
          #                             the path that priv/ exists in.
          #   "static_files"         -- directory to look for files in
          {"/static/[...]", :cowboy_static, {:priv_dir,  :snapchat, "static"}},

          # Serve websocket requests.
          {"/ws", Snapchat.WebsocketHandler, []}
      ]}
    ])
  end

end
