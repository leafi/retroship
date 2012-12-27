window.App = {}

# delete the 'waiting for script...' line
$('#log').html ''

start = new Date().getTime()
App.status = status = (s) ->
  if console?
    console.log s

  t = (new Date().getTime() - start) / 1000
  $('#log').html "<tr><td>#{t}</td><td>#{s}</td></tr>#{$('#log').html()}"
  #$('#status').html s

App.status "main.coffee has begun!"

App.tiles = {}
App.objects = {}
App.players = {}
App.collision = {}

# App.graphics is set up by rendering.coffee

# App.actionHandlers is set up by handlers.coffee
App.actionHandlers = {}
