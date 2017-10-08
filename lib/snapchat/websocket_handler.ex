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
    Logger.debug "websocket init."
    user_pid = Snapchat.User.start_link(self())
    {:cowboy_websocket, req, %{user_pid: user_pid}}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, state) do
    Logger.debug "websocket terminate."
    Snapchat.Matcher.del_user state.user_pid
    :ok
  end

  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # websocket_handle deals with messages coming in over the websocket,
  # including text, binary, ping or pong messages. But you need not
  # handle ping/pong, cowboy takes care of that.
  def websocket_handle({:text, content}, req, state) do
    Logger.debug "websocket_handle: " <> content <> " state: " <> inspect(state)

    # Use JSX to decode the JSON message and extract the word entered
    # by the user into the variable 'message'.
    { :ok, %{ "message" => message} } = JSX.decode(content)

    Snapchat.User.send_matcher_message state.user_pid, message

    { :ok, mysend } = JSX.encode(%{ send: message})
    {:reply, {:text, mysend}, req, state}
    # Reverse the message and use JSX to re-encode a reply contatining
    # the reversed message.
    # rev = String.reverse(message)
    # { :ok, reply } = JSX.encode(%{ message: rev})

    # All websocket callbacks share the same return values.
    # See http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_websocket/
    # {:reply, {:text, reply}, req, state}
  end

  # Fallback clause for websocket_handle.  If the previous one does not match
  # this one just ignores the frame and returns `{:ok, state}` without
  # taking any action. A proper app should  probably intelligently handle
  # unexpected messages.
  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  # websocket_info is the required callback that gets called when erlang/elixir
  # messages are sent to the handler process.
  # In a larger app various clauses of websocket_info might handle all kinds
  # of messages and pass information out the websocket to the client.

  def websocket_info({:message, message}, req, state) do
    {:ok, message} = JSX.encode(%{message: message})
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

end
