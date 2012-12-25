
cx = $('#canvas')[0].offsetLeft
cy = $('#canvas')[0].offsetTop
$('body').on('contextmenu', () -> false)
$('#canvas').mousedown (mev) ->
  # normalize mouse coords... yeesh
  if mev.offsetX? and mev.offsetY?
    mx = mev.offsetX
    my = mev.offsetY
  else
    mx = mev.pageX - cx
    my = mev.pageY - cy

  # what tile was clicked?
  [x, y] = App.graphics.mouseToTileCoords mx, my

  # anything on that tile?
  for depth, layer of App.tiles
    if layer? and layer[y]? and layer[y][x]?
      [a,b,chandle] = layer[y][x]
      console.log "-chandle #{chandle}"
      if App.objects[chandle]?
        o = App.objects[chandle]
        console.log "-- got o"
        if o.type? and App.actionHandlers[o.type]?
          App.ah = ah = App.actionHandlers[o.type]
          console.log "--- ahhhh for type #{o.type}  +  #{JSON.stringify ah}"
          if mev.which == 1 # LMB
            if ah.leftClick?
              ah.leftClick o, (p) -> App.netsend {id: 'ACTION', chandle: chandle, p: p}
          else # RMB or w/e dontcare
            if ah.rightClick?
              ah.rightClick o, (p) -> App.netsend {id: 'ACTION', chandle: chandle, p: p}
        else
          alert "No action handler set client-side for object of type '#{o.type}'!  (Add the entry to client/handlers.coffee?)"

      else
        App.status ' clicked tile contained object, but the object hasn\'t been synced to the client!!'
