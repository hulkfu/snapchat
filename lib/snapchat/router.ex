defmodule Snapchat.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200,
      """
      <head>
      <script>
      wsServer = 'ws://localhost:4000/ws';
      websocket = new WebSocket(wsServer);

      websocket.onopen = function (evt) { websocket.send("ping") };
      function onMessage(evt) {
        console.log('Retrieved data from server: ' + evt.data);
      }
      websocket.onmessage = function (evt) { onMessage(evt) };

      </script>
      </head>

      <body>
      <h1>Snapchat</h1>
      <ul>
        <li>hello</li>
      </ul>
      <form>
        <input placeholder="to say..." name="say" type="text" autofocus="">
        <button type="submit" tabindex="1">Say</button>
      </form>
      </body>
      """)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
