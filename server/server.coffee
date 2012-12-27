#require('coffeescript') # we import coffeescript files

# host web server (to serve static client assets)
console.log 'start host web server'
connect = require('connect')
assethost = connect()
  .use(connect.logger 'dev')
  .use(connect.static __dirname + '/../client')
  .use(connect.staticCache)
  .listen 8080

# host game server
console.log 'start host web socket (game) server'
WebSocketServer = require('ws').Server
wss = new WebSocketServer {port: 8081}

cstate = require('./client-state')
allsockets = []
playersToSockets = {}

Door = require('./Door').Door

# BEGIN TEST MAP
d1 = new Door 1, 1
d2 = new Door 2, 2
d3 = new Door 3, 3
d4 = new Door 4, 4
d5 = new Door 5, 5

ExampleBox = require('./ExampleBox').ExampleBox
eb1 = new ExampleBox 2, 1
eb2 = new ExampleBox 3, 1
eb3 = new ExampleBox 4, 1
# END TEST MAP

wss.on 'connection', (ws) ->
  console.log 'got a connection!'
  allsockets.push(ws)
  ws.on 'close', (code, error) ->
    console.log "socket closed. #{code} #{error}"
    allsockets = allsockets.filter (el) -> el != ws
  ws.on 'message', (packet) ->
    console.log "received: #{packet}"
    msg = JSON.parse packet
    switch msg.id
      when 'HELLO'
        console.log ' client said hello - sending data...'
        # send everything
        sendSocket ws, cstate.createWelcomePacket()

      when 'ACTION'
        # !!!!!!!!!!!!!!!!!
        # TODO: UNCOMMENT THIS WHEN PLAYER LOGGING IN WORKS
        # !!!!!!!!!!!!!!!!!
        #if not ws.player?
        #  console.log "ACTION from player who isn't logged in; ignoring."
        #  return

        console.log " ACTION from client to server object holding chandle #{msg.chandle}, giving packet #{JSON.stringify(msg.p)}"
        if msg.chandle? and msg.p?
          so = cstate.getServerObjectForChandle msg.chandle
          if so?
            if so.action?
              so.action (cstate.getPlayer ws.player), msg.p
            else
              console.log '  ^ ACTION went to server object that doesn\'t support actions. ignoring.'
          else
            console.log '  ^ failed to find a server object holding that chandle! ignoring.'
        else
          console.log ' ACTION with invalid chandle and/or invalid packet. weird. ignoring. (client out of sync?) probably harmless.'

      when 'REGISTER'
        # already registered? KILL!
        if ws.player?
          ws.close()
          return

        ws.player = cstate.addPlayer {name: msg.name, inventory: [], active: [], x: 0, y: 0}
        cstate.updatePlayer ws.player, {id: ws.player}
        playersToSockets[ws.player] = ws
        console.log "Player #{name} registers a connection."

        sendSocket ws, {id: 'REGISTERED'}

      when 'ADMIN_REGISTER'
        # just always accept for now
        ws.admin = true
        console.log "Player #{if ws.player? then cstate.players()[ws.player].name else "(not registered)"} elevates to administrator"

      else
        ws.close()
        console.log "client killed due to received message with nonsensical id '#{msg.id}'"

sendSocket = (ws, p) ->
  ws.send (JSON.stringify p)

sendPlayer = (player, p) ->
  playersToSockets[player].send (JSON.stringify p)

sendAll = (p) ->
  s = JSON.stringify p
  for ws in allsockets
    ws.send s

# transmit deltas to all clients, 10 times a second
setInterval(() ->
  delta = cstate.compileUpdates()
  if delta?
    sendAll delta
, 100)

