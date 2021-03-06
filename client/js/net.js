// Generated by CoffeeScript 1.4.0
(function() {
  var connect, url, ws;

  ws = {};

  connect = function(url) {
    ws = new WebSocket(url);
    ws.onclose = function() {
      return App.status("<h1>Connection closed!</h1> Is the server up? TODO: something appropriate here");
    };
    ws.onopen = function() {
      App.status("Connection established.");
      return ws.send(JSON.stringify({
        id: "HELLO"
      }));
    };
    ws.onerror = function(err) {
      return App.status(err);
    };
    return ws.onmessage = function(packet) {
      var msg;
      console.log("got message " + packet.data + "! :3");
      msg = JSON.parse(packet.data);
      switch (msg.id) {
        case 'WELCOME':
          App.status("I got a hi back. I am happy.");
          App.objects = msg.objects;
          App.players = msg.players;
          App.tiles = msg.tiles;
          return App.collision = msg.collision;
        case 'UPDATE':
          App.status("Updating objects/tiles (changed: " + ($.objectSize(msg.objects)) + ", " + ($.objectSize(msg.tiles)) + ")");
          App.objects = $.extend(true, App.objects, msg.objects);
          App.players = $.extend(true, App.players, msg.players);
          App.tiles = $.extend(true, App.tiles, msg.tiles);
          return App.collision = $.extend(true, App.collision, msg.collision);
        case 'REGISTERED':
          return App.status("Joined the game successfully!");
        default:
          return App.status("Could not understand packet " + msg.id + ". Ignoring.");
      }
    };
  };

  App.netsend = function(m) {
    if (ws != null) {
      return ws.send(JSON.stringify(m));
    }
  };

  url = 'ws://localhost:8081/retroship';

  App.status("Connecting to server " + url + "...");

  connect(url);

}).call(this);
