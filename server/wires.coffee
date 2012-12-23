wires = []
wireIns = []
wireOuts = []

exports.red = "red"
exports.yellow = "yellow"
exports.green = "green"
exports.blue = "blue"
exports.white = "white"
exports.black = "black"

# signal api: 1, 0, 'X' (unknown), 'Z' (high impedance)

# colour == null to unsolder all wires
exports.unsolder = (source, colour) ->
  dcol = (col) ->
    if wireOuts[source][col]?
      dsts = wireOuts[source][colour]
      for dst in dsts
        if wireIns[dst]? and wireIns[dst][colour]?
          wireIns[dst][colour] = wireIns[dst][colour].filter((el) -> el != source)
      delete wireOuts[source][col]

  if colour?
    dcol colour
  else
    for c in wireOuts[source]
      dcol c

exports.cutWire = (x, y, colour) ->
  console.log "TODO: cut the wire!"

# (sourcex .. dsty are currently unused, but will in the future be used
#  to put wires down on the floor between the objects.)
exports.solder = (source, dst, colour, sourcex, sourcey, dstx, dsty) ->
  # if dst isn't capable of being soldered, don't do anything
  if not dst.signalIn?
    console.log "wiring failed; dst doesn't accept electrical input"
    return

  # TODO: generate visible wiring objects

  if not wireOuts[source]?
    wireOuts[source] = []
  if not wireOuts[source][colour]?
    wireOuts[source][colour] = []

  if not wireIns[dst]?
    wireIns[dst] = []
  if not wireIns[dst][colour]?
    wireIns[dst][colour] = []

  # TODO: disallow double soldering??
  wireOuts[source][colour].push dst
  wireIns[dst][colour].push source

# amount guidance: 240 'amount' is mains. (i was thinking more power than voltage, though..)
# colour can be null to represent all colours.
# 'amount' is given to each neighbour, not split between them! (i know, i suck)
# NOTE THAT SPECIFYING NO COLOUR IS THE ONLY WAY TO FRY INPUTS!!!
exports.fryNeighbours = (source, colour, amount) ->
  friedAny = false

  # TODO: consider burning out wires/fuses along the way
  fry = (wireList) ->
    for w in wireList
      if w.damagingSignalIn?
        w.damagingSignalIn colour, amount
      else if w.resist?
        w.resist {electrical: true, viaWiring: true}, amount
      friedAny = true

  if colour?
    if wireOuts[source]? and wireOuts[source][colour]?
      fry wireOuts[source][colour]

  else # don't care about the colour? (means we should fry inputs, too.)
    if wireOuts[source]?
      for colour in wireOuts[source]
        fry wireOuts[source][colour]

    if wireIns[source]?
      for colour in wireIns[source]
        fry wireIns[source][colour]

  return friedAny

# signal api: 1, 0, 'X' (unknown), 'Z' (high impedance)
# TODO: do something clever for Z...
exports.signal = (source, colour, signal) ->
  # may as well sort this out here...
  if signal == '1'
    signal = 1
  else if signal == '0'
    signal = 0

  # if any wires are connected, tell them about the signal change.
  if wireOuts[source]? and wireOuts[source][colour]?
    for dst in wireOuts[source][colour]
      if dst.signalIn?
        dst.signalIn colour, signal

