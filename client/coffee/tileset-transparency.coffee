# makes the given colour in an image, transparent.
#
# i do this because i can't figure out how to export tilemaps from
#  Tile Studio with real png transparency...

App.makeTilesetTransparent = (img) ->
  # create temp canvas
  ca = document.createElement('canvas')
  c = ca.getContext('2d')
  c.width = img.width
  c.height = img.height

  # draw source image to temp canvas
  c.drawImage img, 0, 0

  # capture temp canvas' pixel data
  pd = c.getImageData 0, 0, img.width, img.height
  d = pd.data

  for i in [0...(d.length/4)]
    # if r==110, g==220, b==116, then set a to 0
    # canvas pixel data uses RGBA order!
    if d[i*4] == 110 and d[i*4+1] == 220 and d[i*4+2] == 116
      d[i*4+3] = 0

  # draw changes back to canvas, & capture as new image
  c.putImageData pd, 0, 0
  result = new Image()
  result.src = ca.toDataURL("image/png")

  return result
