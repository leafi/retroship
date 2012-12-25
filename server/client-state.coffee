$ = require('jquery')
collision = require('./collision')

# client-side stuff
objects = {}
tiles = {}
players = {}

# used to map client-side objects to server-side objects.
# (...so that when you interact with a tile on the client, the correct server object
#     gets the input.)
chandleToServerObject = {}

objectsDelta = {}
tilesDelta = {}
playersDelta = {}

nextObjectId = 1
nextPlayerId = 1

exports.objects = () -> objects
exports.tiles = () -> tiles
exports.players = () -> players

exports.addObject = (serverObj, obj) ->
  id = nextObjectId
  objects[id] = obj
  objectsDelta[id] = obj
  chandleToServerObject[id] = serverObj
  # note: assumes we never re-use ids
  nextObjectId++
  return id

exports.addPlayer = (p) ->
  id = nextPlayerId
  players[id] = p
  playersDelta[id] = p
  # note: assumes we never re-use ids
  nextPlayerId++
  return id

exports.removeObject = (id) ->
  delete objects[id]
  delete chandleToServerObject[id]
  objectsDelta[id] = null # erase client-side, too

exports.removePlayer = (id) ->
  delete players[id]
  playersDelta[id] = null # erase client-side, too

exports.removeTile = (layer, x, y) ->
  ts = {}
  ts[layer] = {}
  ts[layer][y] = {}
  ts[layer][y][x] = null
  exports.updateTiles ts

exports.updateObject = (id, delta) ->
  objects[id] = $.extend true, objects[id], delta
  # TODO: omit unnecessary object information
  objectsDelta[id] = $.extend true, objectsDelta[id], delta

exports.getServerObjectForChandle = (chandle) ->
  return chandleToServerObject[chandle]

exports.updateTiles = (delta) ->
  #console.log "! UPDATE TILES !"
  #console.log "Given delta is #{JSON.stringify delta}"
  #console.log "Before update, tiles: #{JSON.stringify tiles}"
  tiles = $.extend true, tiles, delta
  #console.log "After update, tiles: #{JSON.stringify tiles}"
  #console.log "Before update delta: #{JSON.stringify tilesDelta}"
  # TODO: omit unnecessary tile information
  tilesDelta = $.extend true, tilesDelta, delta
  #console.log "After update delta: #{JSON.stringify tilesDelta}"


exports.updateTile = (layer, x, y, txy, chandle) ->
  [tx, ty] = txy

  ts = {}
  ts[layer] = {}
  ts[layer][y] = {}
  ts[layer][y][x] = [tx, ty, chandle]

  exports.updateTiles ts

exports.updateTilePaint = (layer, x, y, txy) ->
  if tiles[layer] and tiles[layer][y] and tiles[layer][y][x]
    t = tiles[layer][y][x]
  else
    t = [null, null, null]

  # a tile is a quad (spritesheet x), (spritesheet y), (chandle)
  [a, b, c] = t
  [tx, ty] = txy

  ts = {}
  ts[layer] = {}
  ts[layer][y] = {}
  ts[layer][y][x] = [tx, ty, c]

  exports.updateTiles ts

exports.updatePlayer = (id, delta) ->
  players[id] = $.extend true, players[id], delta
  # TODO: omit unnecessary delta info
  playersDelta[id] = $.extend true, playersDelta[id], delta

exports.createWelcomePacket = () ->
  {id: 'WELCOME', objects: objects, tiles: tiles, players: players, collision: collision}

exports.compileUpdates = () ->
  collisionDelta = collision.compileUpdates()

  objectSize = (obj) ->
    count = 0
    for k, v of obj
      if obj.hasOwnProperty k
        count++
    return count

  if objectSize(objectsDelta) + objectSize(tilesDelta) + objectSize(playersDelta) + objectSize(collisionDelta) == 0
    return null
  else
    r = {id: 'UPDATE', objects: objectsDelta, tiles: tilesDelta, players: playersDelta, collision: collisionDelta}
    objectsDelta = {}
    tilesDelta = {}
    playersDelta = {}
    return r
