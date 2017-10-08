defmodule Snapchat.WebsocketHandler do
  require Logger

  @behaviour :cowboy_websocket

  # We are using the regular http init callback to perform handshake.
  #     http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_handler/
  #
  # Note that handshake will fail if this isn't a websocket upgrade request.
  # Also, if your server implementation supports subprotocols,
  # init is the place to parse `sec-websocket-protocol` header
  # then add the same header to `req` with value containing
  # supported protocol(s).
  def init(req, state) do
    :erlang.start_timer(1000, self(), [])
    Logger.debug "websocket init."
    Snapchat.User.start_link(self())
    {:cowboy_websocket, req, state}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    :ok
  end

  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # websocket_handle deals with messages coming in over the websocket,
  # including text, binary, ping or pong messages. But you need not
  # handle ping/pong, cowboy takes care of that.
  def websocket_handle({:text, content}, req, state) do
    Logger.debug "websocket_handle: " <> content

    # Use JSX to decode the JSON message and extract the word entered
    # by the user into the variable 'message'.
    { :ok, %{ "message" => message} } = JSX.decode(content)

    # Reverse the message and use JSX to re-encode a reply contatining
    # the reversed message.
    rev = String.reverse(message)
    { :ok, reply } = JSX.encode(%{ reply: rev})

    # All websocket callbacks share the same return values.
    # See http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_websocket/
    {:reply, {:text, reply}, req, state}
  end

  # Fallback clause for websocket_handle.  If the previous one does not match
  # this one just ignores the frame and returns `{:ok, state}` without
  # taking any action. A proper app should  probably intelligently handle
  # unexpected messages.
  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  # websocket_info is the required callback that gets called when erlang/elixir
  # messages are sent to the handler process. In this example, the only erlang
  # messages we are passing are the :timeout messages from the timing loop.
  #
  # In a larger app various clauses of websocket_info might handle all kinds
  # of messages and pass information out the websocket to the client.
  def websocket_info({_timeout, _ref, _msg}, req, state) do

    time = time_as_string()

    # encode a json reply in the variable 'message'
    { :ok, message } = JSX.encode(%{ time: time})

    # set a new timer to send a :timeout message back to this
    # process a second from now. This will recursively call
    # this handler, acting as a tick.
    :erlang.start_timer(1000, self(), [])

    # send the new message to the client. Note that even though there was no
    # incoming message from the client, we still call the outbound message
    # a 'reply'.  That makes the format for outbound websocket messages
    # exactly the same as websocket_handle()
    { :reply, {:text, message}, req, state}
  end

  def websocket_info({:message, message}, req, state) do
    {:ok, message} = JSX.encode(%{reply: message})
    {:reply, {:text, message}, req, state}
  end

  def websocket_info({:status, status}, req, state) do
    {:ok, message} = JSX.encode(%{status: status})
    {:reply, {:text, message}, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    Logger.debug "websocket_info: " <> message
    {:reply, {:text, message}, req, state}
  end

  # fallback message handler
  def websocket_info(_info, _req, state) do
    {:ok, state}
  end

  def time_as_string do
    {hh, mm, ss} = :erlang.time()
    :io_lib.format("~2.10.0B:~2.10.0B:~2.10.0B", [hh, mm, ss])
    |> :erlang.list_to_binary()
  end

end
