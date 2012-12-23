window.App = {}

App.status = status = (s) ->
  if console?
    console.log s
  $('#status').html s

App.status "main.coffee has begun!"

App.tiles = {}
App.objects = {}
App.players = {}
App.collision = {}

# App.graphics is set up by rendering.coffee

# App.actionHandlers is set up by handlers.coffee
App.actionHandlers = {}
