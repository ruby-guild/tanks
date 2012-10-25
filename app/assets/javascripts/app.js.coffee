@App =
  websocket: new WebSocket("ws://127.0.0.1:8080")
  init: ->
    App.WebGL.init $('#game-canvas')[0]

