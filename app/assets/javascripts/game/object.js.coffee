class App.classes.GameObject
  position: [0.0, 0.0]
  angle: 0
  texture: null

  vertexBuffer: null
  textureBuffer: null
  indexBuffer: null

  constructor: (gl, vertices) ->
    @gl = gl
    @initBuffers()
    @initTextures()

  initBuffers: (vertices = null) ->
    # vertex buffer
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

    # texture buffer
    @textureBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @textureBuffer

    texture_coords = [
      0.0, 0.0,
      1.0, 1,
      1.0, 0.0,
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(texture_coords), @gl.STATIC_DRAW
    @textureBuffer.itemSize = 2
    @textureBuffer.numItems = texture_coords.length / @textureBuffer.itemSize

    # index buffer
    @indexBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @indexBuffer

    indices = [0, 1, 2]

    @gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), @gl.STATIC_DRAW
    @indexBuffer.itemSize = 1
    @indexBuffer.numItems = indices.length / @indexBuffer.itemSize

  initTextures: ->
    @texture = @gl.createTexture()
    image = new Image()

    that = @
    image.onload = ->
      that.handleTextureLoaded image, that.texture

    image.src = "/assets/cubetexture.png"
    return

  handleTextureLoaded: (image, texture) ->
    @gl.bindTexture @gl.TEXTURE_2D, texture
    @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, image
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST
    @gl.generateMipmap @gl.TEXTURE_2D
    @gl.bindTexture @gl.TEXTURE_2D, null

  move: (position, angle) ->
    @position = position
    @angle = angle