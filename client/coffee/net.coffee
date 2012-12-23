ws = {}

connect = (url) ->
  ws = new WebSocket url
  ws.onclose = () -> status "<h1>Connection closed!</h1> Is the server up? TODO: something appropriate here"
  ws.onopen = () ->
    App.status "Connection established."
    ws.send (JSON.stringify {id: "HELLO"})
  ws.onerror = (err) -> status err # TODO something better

  ws.onmessage = (packet) ->
    console.log "got message #{packet.data}! :3"
    msg = JSON.parse packet.data

    switch msg.id
      when 'WELCOME'
        App.status "I got a hi back. I am happy."
        App.objects = msg.objects
        App.players = msg.players
        App.tiles = msg.tiles
        App.collision = msg.collision
      when 'UPDATE'
        App.status "Updating objects/tiles (changed: #{$.objectSize(msg.objects)}, #{$.objectSize(msg.tiles)})"
        App.objects = $.extend true, App.objects, msg.objects
        App.players = $.extend true, App.players, msg.players
        App.tiles = $.extend true, App.tiles, msg.tiles
        App.collision = $.extend true, App.collision, msg.collision
      else
        App.status "Could not understand packet #{msg.id}. Ignoring."

App.netsend = (m) ->
  if ws?
    ws.send (JSON.stringify m)

url = 'ws://localhost:8080/retroship'
App.status "Connecting to server #{url}..."

connect url