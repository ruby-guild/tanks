class App.classes.GameObject
  position: [0.0, 0.0]
  angle: 0

  vertexBuffer: null

  constructor: (gl, vertices) ->
    @gl = gl
    @initBuffers()

  initBuffers: (vertices = null) ->
    @vertexBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @vertexBuffer

    vertices = vertices || [
      -0.5, -0.5,  0.0,
      -0.5, 0.5,  0.0,
      0.5, 0.0, 0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @vertexBuffer.itemSize = 3
    @vertexBuffer.numItems = vertices.length / 3

  move: (position, angle) ->
    @position = position
    @angle = angle