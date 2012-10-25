@App.WebGL =
  init: (canvas) ->
    try
      gl = canvas.getContext("experimental-webgl")
      gl.viewport(0, 0, canvas.width, canvas.height)
      console.log "Inited successfully"
    catch e
      console.log e.message
    if !gl
      alert "Could not initialise WebGL"