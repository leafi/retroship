$ = require('jquery')

collision = {}
collisionDelta = {}

exports.collision = () -> collision

exports.updateTiles = (delta) ->
  collision = $.extend true, collision, delta
  collisionDelta = $.extend true, collisionDelta, delta

exports.updateTile = (x,y,r) ->
  c = {}
  c[y] = {}
  c[y][x] = [r]
  exports.updateTiles r

###
exports.block = (x,y) ->
  if collision[y]? and collision[y][x]?
    exports.updateTile x, y, collision[y][x] + 1
  else
    exports.updateTile x, y, 1

exports.unblock = (x,y) ->
  if collision[y]? and collision[y][x]?
    exports.updateTile x, y, collision[y][x] - 1
  else
    exports.updateTile x, y, 0
###

exports.set = (x,y,s) ->
  if s
    #exports.updateTile x, y, 999
    exports.updateTile x, y, true
  else
    #exports.updateTile x, y, -999
    exports.updateTile x, y, false

# used by client-state.coffee
exports.compileUpdates = () ->
  cd = collisionDelta
  collisionDelta = {}
  return cd