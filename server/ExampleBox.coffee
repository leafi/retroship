cstate = require('./client-state')
sprites = require('./sprites')
collision = require('./collision')

# A box that switchen between red and yellow as you click it.
class ExampleBox

  # Required* functions for server-side objects:
  #  constructor (obviously), action, destroy, resist
  #
  # (* not really required. most objects will need them though.)

  constructor: (@x, @y) ->
    # Internal state.  Is the box currently red, or yellow?
    @yellow = false
    # How many times has the box been clicked so far?
    @times = 0

    # Create a client-side object.
    # This is necessary because we want the user to be able to interact with the
    #  box, and click to change its colour.
    # If the user doesn't have to interact with it directly, don't bother with this.
    @chandle = cstate.addObject this, {type: 'CExampleBox', clickedFiveTimes: false}
    # ^ The first parameter, this, is used when actions are received from the client.
    #    The client only knows about the client-side object, so a map is maintained
    #     in cstate from client-side objects to server-side ones.

    #    You don't have to pass 'this'; you could pass something else that has an action
    #     function.

    # ^ W.r.t. the client-side object itself - the second parameter -
    #     'type' is used in client/coffee/handlers.coffee to choose what happens.
    #   Other than that, there's no restrictions on what you put in the client rep.

    # Plonks the tile down.
    # We pass the chandle so the client knows that actions can be done to the tile.
    cstate.updateTile sprites.layerObstructions, @x, @y, sprites.redBox, @chandle

  action: (from, p) ->
    # if we receive an 'activate' message from the client...
    if p.action == 'ACTIVATE'
      # ...switch the box colour!
      @yellow = not @yellow

      # update the tile!
      cstate.updateTilePaint sprites.layerObstructions, @x, @y, if @yellow then sprites.yellowBox else sprites.redBox

      # update times clicked count!
      @times++
      # have we just gone from 4 to 5 clicks?
      if @times == 5
        # ...then tell the client this, so it can start warning the user when they click.
        # we don't want them to get RSI!
        # {see client/coffee/handlers.coffee)
        cstate.updateObject @chandle, {clickedFiveTimes: true}
        # (note we don't provide 'type' or anything else again.
        #  updateObject merges the original object with what you give it.)

  destroy: () ->
    # If you have any timers running or anything, this is a great time to tear them down.
    # We'll just delete some functions so the user can't interact with us anymore,
    #  and remove our tile and client-side object.
    cstate.removeTile sprites.layerObstructions, @x, @y
    cstate.removeObject @chandle
    @action = @destroy = @chandle = @resist = null

  resist: (dmgType, amount) ->
    # We'll just break as soon as anything damages us.
    # It is a very flimsy box.
    # (See DoorSwitch if you want a more interesting resist func.)

    return false # fail to resist damage


# export us!
exports.ExampleBox = ExampleBox