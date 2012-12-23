if not $('#canvas')?
  App.status "Couldn't find &lt;canvas&gt; tag; cannot continue!"
  return

ctx = $('#canvas')[0].getContext('2d')

if not ctx?
  App.status "Failed to get &lt;canvas&gt; 2D context. Cannot continue."
  return

# set background to black
ctx.fillStyle = "black"
ctx.fillRect(0, 0, 640, 400)

class Graphics
  constructor: (@ctx) ->
    @camera = {
      x: 0
      y: 0
      bounds: () -> {x1: @camera.x, y1: @camera.y, x2: @camera.x + 640, y2: @camera.y + 400}
    }
    @spritesheet = null
    @tilesize = 32

  mouseToTileCoords: (mousex, mousey) ->
    return [Math.floor((mousex + @camera.x) / @tilesize), Math.floor((mousey + @camera.y) / @tilesize)]

  drawTile: (tile, screenx, screeny) ->
    if not tile?
      return
    [tx, ty, chandle] = tile
    #App.status screenx + "," + screeny
    if @spritesheet?
      @ctx.drawImage @spritesheet, tx * @tilesize, ty * @tilesize, @tilesize, @tilesize, screenx, screeny, @tilesize, @tilesize
    else
      App.status "trying to draw tile, but spritesheet isn't loaded!"

  drawTiles: (paintlayer) ->
    x1 = @camera.x
    y1 = @camera.y
    tx1 = Math.floor(x1 / @tilesize)
    ty1 = Math.floor(y1 / @tilesize)
    modx = -x1 % @tilesize
    mody = -y1 % @tilesize

    for y in [0..400/@tilesize]
      for x in [0..640/@tilesize]
        if paintlayer? # hmm
          if paintlayer[y+ty1]?
            @drawTile paintlayer[y+ty1][x+tx1], x*@tilesize + modx, y*@tilesize + mody
        else
          @drawTile [0,0], x*@tilesize + modx, y*@tilesize + mody

  draw: () ->
    # clear to black
    #ctx.fillRect(0, 0, 640, 400)

    # Render layers in the correct order.
    # (Layers with greater (more positive) depth values are rendered on top of ones with lesser.)
    # Probably inefficient doing this every frame; sue me.
    ks = Object.keys(App.tiles).slice(0).sort()

    for depth in ks
      @drawTiles(App.tiles[depth])


App.graphics = new Graphics ctx

# try to load spritesheet
sprs = new Image

$(sprs).on('load', () ->

  App.status "Loaded spritesheet!"
  App.graphics.spritesheet = sprs

  # start renderer!
  setInterval(() ->
    #App.graphics.camera.x++
    App.graphics.draw()
  , 10)

)

$(sprs).on('error', () -> App.status "Spritesheet load FAILED")

App.status "Loading spritesheet..."
sprs.src = "res/tiles.png"
