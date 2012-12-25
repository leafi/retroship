cstate = require('./client-state')
collision = require('./collision')
wires = require('./wires')
sprites = require('./sprites')

#
# A door that takes 0.5s to switch states.
# (If switching is request while it's already in the process of switching, the request
#   is simply discarded.)
#

# The server instantiates only the Door class.
# DoorModel is purely for internal use by Door, below this class!
class DoorModel
  constructor: (@onDelayedToggle) ->
    @open = false

  # returns: toggling door state succeeded?
  toggle: () ->
    if @waitTimer?
      console.log "toggle: Door is already toggling.  Ignoring request."
      return false
    else
      console.log 'toggle: Not waiting for existing toggling; let\'s toggle!'

    console.log "toggle: setting up timer. door lock will be released when timer expires.."

    @open = not @open

    that = this

    # timer for actually changing the tile
    @waitTimer = setTimeout(() ->
      console.log "toggle: timer expired; allow the door to be toggled again!"
      that.waitTimer = null
      #that.open = not that.open
      #that.onDelayedToggle()
    , 500)

    # timer for relinquishing the lock, and allowing the door state to be toggled again


    # false, because we haven't actually toggled the door state yet!
    return true

  destroy: () ->
    if @waitTimer?
      clearTimeout @waitTimer
    @toggle = @waitTimer = null
    @open = false


class Door
  constructor: (@x, @y) ->
    that = this
    @model = new DoorModel(() -> that.updateEverything())
    @chandle = cstate.addObject this, {type: 'CDoor', open: @model.open, hp: @hp, x: @x, y: @y}
    @updateEverything()

  # private function; not part of the usual server-side object API
  updateEverything: () ->
    #cstate.updateTile sprites.layerObstructions, @x, @y, if @model.open then sprites.openDoor else sprites.closedDoor, @chandle
    if @model.open
      cstate.updateTile sprites.layerObstructions, @x, @y, sprites.openDoor, @chandle
    else
      cstate.updateTile sprites.layerObstructions, @x, @y, sprites.closedDoor, @chandle
    cstate.updateObject @chandle, {open: @model.open}
    collision.set @x, @y, not @model.open

  destroy: () ->
    @destroy = @toggle = @action = @signalIn = @resist = null
    @model.destroy()
    @updateEverything()
    cstate.removeTile sprites.layerObstructions, @x, @y

  toggle: () ->
    if @model.toggle()
      @updateEverything()

  action: (from, p) ->
    # TODO: check from!!
    if p.action == 'ACTIVATE'
      @toggle()

  signalIn: (colour, signal) ->
    # don't care about colour. we only have one input.
    if signal == 1 and (@lastSignal != 1)
      @toggle()
    @lastSignal = signal

  resist: (dmgType, amount) ->
    # strong against electrical damage; only pass it on if it's really strong,
    #   and you can't fry a door (reasonable b/c GAMEPLAY)
    # physical damage is what we're interested in.  we're pretty strong against
    #   physical damage, too, but if you 'kill' us, the path will be opened.
    if dmgType.electrical
      if amount > 1000
        wires.fryNeighbours this, null, amount * 0.67
    else
      @hp -= amount
      state.updateObject @chandle, {hp: @hp}

    # did we survive?
    return @hp > 0


exports.Door = Door