# Just some layers.
exports.layerObstructions = 10 # e.g. walls, doors, ...
exports.layerFloor = -10
exports.layerControlPanels = 15 # things on top of walls

# Indexes into the spritesheet client/res/tiles.png.
# e.g. [0,0] indicates the topmost leftmost tile, [1,0] indicates the one to its right, ...

exports.closedDoor = [1,0]
exports.openDoor = [2,0]

exports.doorSwitchOn = [0,0] # TODO
exports.doorSwitchOff = [0,0] # TODO

exports.redBox = [0,1]
exports.yellowBox = [1,1]