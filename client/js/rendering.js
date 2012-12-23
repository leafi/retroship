// Generated by CoffeeScript 1.4.0
(function() {
  var Graphics, ctx, sprs;

  if ($('#canvas') == null) {
    App.status("Couldn't find &lt;canvas&gt; tag; cannot continue!");
    return;
  }

  ctx = $('#canvas')[0].getContext('2d');

  if (ctx == null) {
    App.status("Failed to get &lt;canvas&gt; 2D context. Cannot continue.");
    return;
  }

  ctx.fillStyle = "black";

  ctx.fillRect(0, 0, 640, 400);

  Graphics = (function() {

    function Graphics(ctx) {
      this.ctx = ctx;
      this.camera = {
        x: 0,
        y: 0,
        bounds: function() {
          return {
            x1: this.camera.x,
            y1: this.camera.y,
            x2: this.camera.x + 640,
            y2: this.camera.y + 400
          };
        }
      };
      this.spritesheet = null;
      this.tilesize = 32;
    }

    Graphics.prototype.mouseToTileCoords = function(mousex, mousey) {
      return [Math.floor((mousex + this.camera.x) / this.tilesize), Math.floor((mousey + this.camera.y) / this.tilesize)];
    };

    Graphics.prototype.drawTile = function(tile, screenx, screeny) {
      var chandle, tx, ty;
      if (tile == null) {
        return;
      }
      tx = tile[0], ty = tile[1], chandle = tile[2];
      if (this.spritesheet != null) {
        return this.ctx.drawImage(this.spritesheet, tx * this.tilesize, ty * this.tilesize, this.tilesize, this.tilesize, screenx, screeny, this.tilesize, this.tilesize);
      } else {
        return App.status("trying to draw tile, but spritesheet isn't loaded!");
      }
    };

    Graphics.prototype.drawTiles = function(paintlayer) {
      var modx, mody, tx1, ty1, x, x1, y, y1, _i, _ref, _results;
      x1 = this.camera.x;
      y1 = this.camera.y;
      tx1 = Math.floor(x1 / this.tilesize);
      ty1 = Math.floor(y1 / this.tilesize);
      modx = -x1 % this.tilesize;
      mody = -y1 % this.tilesize;
      _results = [];
      for (y = _i = 0, _ref = 400 / this.tilesize; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (x = _j = 0, _ref1 = 640 / this.tilesize; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
            if (paintlayer != null) {
              if (paintlayer[y + ty1] != null) {
                _results1.push(this.drawTile(paintlayer[y + ty1][x + tx1], x * this.tilesize + modx, y * this.tilesize + mody));
              } else {
                _results1.push(void 0);
              }
            } else {
              _results1.push(this.drawTile([0, 0], x * this.tilesize + modx, y * this.tilesize + mody));
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Graphics.prototype.draw = function() {
      var depth, ks, _i, _len, _results;
      ks = Object.keys(App.tiles).slice(0).sort();
      _results = [];
      for (_i = 0, _len = ks.length; _i < _len; _i++) {
        depth = ks[_i];
        _results.push(this.drawTiles(App.tiles[depth]));
      }
      return _results;
    };

    return Graphics;

  })();

  App.graphics = new Graphics(ctx);

  sprs = new Image;

  $(sprs).on('load', function() {
    App.status("Loaded spritesheet!");
    App.graphics.spritesheet = sprs;
    return setInterval(function() {
      return App.graphics.draw();
    }, 10);
  });

  $(sprs).on('error', function() {
    return App.status("Spritesheet load FAILED");
  });

  App.status("Loading spritesheet...");

  sprs.src = "res/tiles.png";

}).call(this);