@App.WebGL =
  gl: null
  shaderProgram: null

  shaders:
    shader_fs:
      type: 'x-shader/x-fragment'
      source: "
        precision mediump float;

        void main(void) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
      "
    shader_vs:
      type: 'x-shader/x-vertex'
      source: "
        attribute vec3 aVertexPosition;

        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        void main(void) {
            gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        }
      "

  init: (canvas) ->
    try
      @gl = canvas.getContext("experimental-webgl")
      @gl.viewport(0, 0, canvas.width, canvas.height)
      @gl.viewportWidth = canvas.width
      @gl.viewportHeight = canvas.height
      console.log "Inited successfully"
    catch e
      console.log e.message
    if !@gl
      alert "Could not initialise WebGL"

    @drawScene()

  getShader: (name) ->
    shader_script = @shaders[name]

    switch shader_script.type
      when "x-shader/x-fragment" then shader_type = @gl.FRAGMENT_SHADER
      when "x-shader/x-vertex" then shader_type = @gl.VERTEX_SHADER
      else return null

    shader = @gl.createShader shader_type

    @gl.shaderSource shader, shader_script.source
    @gl.compileShader shader

    if !@gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
      console.log @gl.getShaderInfoLog(shader)
      return null

    shader

  initShaders: ->
    fragmentShader = @getShader "shader_fs"
    vertexShader = @getShader "shader_vs"

    @shaderProgram = @gl.createProgram()
    @gl.attachShader @shaderProgram, vertexShader
    @gl.attachShader @shaderProgram, fragmentShader
    @gl.linkProgram @shaderProgram

    if !@gl.getProgramParameter(@shaderProgram, @gl.LINK_STATUS)
      console.log "Could not initialise shaders"

    @gl.useProgram @shaderProgram

    @shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, "aVertexPosition"
    @gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

    @shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"

  initBuffers: ->
    triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, triangleVertexPositionBuffer

    vertices = [
      0.0,  1.0,  0.0,
      -1.0, -1.0,  0.0,
      1.0, -1.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    triangleVertexPositionBuffer.itemSize = 3
    triangleVertexPositionBuffer.numItems = 3

    [triangleVertexPositionBuffer]

  setMatrixUniforms: (pMatrix, mvMatrix)->
    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix


  drawScene: ->
    @initShaders()

    buffers = @initBuffers()
    triangleVertexPositionBuffer = buffers[0]

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    pMatrix = mat4.create()
    mvMatrix = mat4.create()

    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, pMatrix
    mat4.identity mvMatrix

    mat4.translate mvMatrix, [0.0, 0.0, -15.0]
    @gl.bindBuffer @gl.ARRAY_BUFFER, triangleVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @setMatrixUniforms pMatrix, mvMatrix
    @gl.drawArrays @gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems
