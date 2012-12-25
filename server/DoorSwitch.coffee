wires = require('./wires')
cstate = require('./client-state')
sprites = require('./sprites')

class DoorSwitch

  # Pulses its output for 200ms when interacted with.

  # action - some external agent is trying to influence the door,
  #           possibly with a tool

  # destroy - destroyed by some external action

  # resist - try and resist some environmental damage of a given amount and type.
  #           returns whether it successfully resisted or not.
  #           (usually if false is returned, a call to destroy will soon
  #             follow.)

  constructor: (@x, @y) ->
    @pulseTime = 200 # ms. should this be in constants.coffee?
    @hp = 100
    @frying = false
    @chandle = state.addObject this, {type: 'CDoorSwitch', pulseTime: @pulseTime, on: false, hp: @hp, frying: @frying, x: @x, y: @y}
    cstate.updateTile sprites.layerControlPanels, @x, @y, sprites.doorSwitchOff, @chandle

  action: (from, p) ->
    # ignore permissions, in range-ness for now
    if p.action == 'ACTIVATE'
      # activate pulse switch.
      @switchOn()
    else if p.action == 'SET'
      @pulseTime = p.pulseTime
      state.updateObject @chandle, {pulseTime: @pulseTime}

  destroy: () ->
    if @timeout?
      clearTimeout @timeout
    wires.signal this, wires.yellow, 'Z'
    wires.unsolder this, null
    state.deleteObject @chandle
    state.removeTile sprites.layerControlPanels, @x, @y
    @action = @tick = @destroy = @resist = @chandle = null

  fry: () ->
    @frying = true
    state.updateObject @chandle, {frying: true}

    # turn-off-switch timer pending? kill it.
    if @timeout?
      clearTimeout @timeout
      @timeout = null

    f = () ->
      r = Math.random()
      if r > 0.2
        if r > 0.75 then s = 1 else s = 'X'
      else
        s = 0
      wires.signal this, null, s

    for i in [0...5]
      setTimeout(f, i * 1000)

    that = this
    setTimeout(() ->
      that.frying = false
      state.updateObject that.chandle, {frying: false}
      # try and fix output
      that.switchOn()
    , 5000)

  resist: (dmgType, dmgAmount) ->
    if dmgType.electrical
      if (dmgType.viaWiring and dmgAmount > 50) or (dmgAmount > 100)
        # go a bit crazy & pass it on!
        wires.fryNeighbours this, null, dmgAmount / 2

        if not @frying
          @fry()

    # in any case, we need to update our hp and return whether we should survive
    if dmgAmount > 10
      @hp -= 5
    if dmgAmount > 2000
      @hp = 0

    cstate.updateObject @chandle, {hp: @hp}
    return @hp > 0

  switchOn: () ->
    if @frying
      return

    cstate.updateTilePaint sprites.layerControlPanels, @x, @y, sprites.doorSwitchOn
    wires.signal this, wires.yellow, 1
    cstate.updateObject @chandle, {on: true}

    if @timeout?
      clearTimeout(@timeout)

    # turn switch off again after (@pulseTime ms)
    that = this
    @timeout = setTimeout(() ->
      cstate.updateTilePaint sprites.layerControlPanels, @x, @y, sprites.doorSwitchOff
      wires.signal that, wires.yellow, 0
      cstate.updateObject @chandle, {on: false}
      that.timeout = null
    , @pulseTime)


exports.DoorSwitch = DoorSwitch