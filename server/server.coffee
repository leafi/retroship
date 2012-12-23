#require('coffeescript') # we import coffeescript files

WebSocketServer = require('ws').Server
wss = new WebSocketServer {port: 8080}

cstate = require('./client-state')
allsockets = []

Door = require('./Door').Door

# BEGIN TEST MAP
d1 = new Door 1, 1
d2 = new Door 2, 2
d3 = new Door 3, 3
d4 = new Door 4, 4
d5 = new Door 5, 5
# END TEST MAP

wss.on 'connection', (ws) ->
  console.log 'got a connection!'
  allsockets.push(ws)
  ws.on 'message', (packet) ->
    console.log "received: #{packet}"
    msg = JSON.parse packet
    switch msg.id
      when 'HELLO'
        console.log ' client said hello - sending data...'
        # send everything
        send ws, cstate.createWelcomePacket()

      when 'ACTION'
        console.log " ACTION from client to server object holding chandle #{msg.chandle}, giving packet #{JSON.stringify(msg.p)}"
        if msg.chandle? and msg.p?
          so = cstate.getServerObjectForChandle msg.chandle
          if so?
            if so.action?
              # TODO: 'ws' probably isn't the right thing to send here
              so.action ws, msg.p
            else
              console.log '  ^ ACTION went to server object that doesn\'t support actions. ignoring.'
          else
            console.log '  ^ failed to find a server object holding that chandle! ignoring.'
        else
          console.log ' ACTION with invalid chandle and/or invalid packet. weird. ignoring. (client out of sync?) probably harmless.'

      else
        ws.close
        console.log "client killed due to received message with nonsensical id '#{msg.id}'"

send = (ws, p) ->
  ws.send (JSON.stringify p)

sendAll = (p) ->
  s = JSON.stringify p
  for ws in allsockets
    if ws? # HACK TEMP FIX
      ws.send s

# transmit deltas to all clients, 10 times a second
setInterval(() ->
  delta = cstate.compileUpdates()
  if delta?
    sendAll delta
, 100)

