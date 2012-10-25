@App.WebGL =
  gl: null
  shaderProgram: null
  pressedKeys: {}

  mvMatrix: mat4.create()
  pMatrix: mat4.create()
  mvMatrixStack: []

  objects: []

  controlled_object_index: 0

  shaders:
    shader_fs:
      type: 'x-shader/x-fragment'
      source: "
        varying highp vec2 vTextureCoord;

        uniform sampler2D uSampler;

        void main(void) {
          gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
        }
      "
    shader_vs:
      type: 'x-shader/x-vertex'
      source: "
        attribute vec3 aVertexPosition;
        attribute vec2 aTextureCoord;

        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        varying highp vec2 vTextureCoord;

        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vTextureCoord = aTextureCoord;
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

    that = @
    $(document).keydown (event) ->
      that.handleKeyDown(event)

    $(document).keyup (event) ->
      that.handleKeyUp(event)

    @addObject(new App.classes.GameObject(@gl))
    obj2 = new App.classes.GameObject(@gl)
    obj2.move [2, 2], 30
    @addObject(obj2)
    obj3 = new App.classes.GameObject(@gl)
    obj3.move [-3, -5], 75
    @addObject(obj3)

    @renderFrame()

  addObject: (obj) ->
    @objects.push obj

  mvPushMatrix: ->
    copy = mat4.create()
    mat4.set @mvMatrix, copy
    @mvMatrixStack.push copy

  mvPopMatrix: ->
    throw "Invalid popMatrix!" if @mvMatrixStack.length == 0
    @mvMatrix = @mvMatrixStack.pop()

  degToRad: (degrees) ->
    degrees * Math.PI / 180

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

    @shaderProgram.textureCoordAttribute = @gl.getAttribLocation @shaderProgram, "aTextureCoord"
    @gl.enableVertexAttribArray @shaderProgram.textureCoordAttribute

    @shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"
    @shaderProgram.samplerUniform = @gl.getUniformLocation @shaderProgram, "uSampler"

  drawScene: ->
    @initShaders()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE
    @gl.enable @gl.BLEND

    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix
    mat4.identity @mvMatrix

    mat4.translate @mvMatrix, [0, 0, -15] # initial translation

    @drawObject(obj) for obj in @objects

  drawObject: (obj) ->
    @mvPushMatrix()

    mat4.translate @mvMatrix, [obj.position[0], obj.position[1], 0]
    mat4.rotate @mvMatrix, @degToRad(obj.angle), [0, 0, 1] # z axis rotation

    @gl.bindBuffer @gl.ARRAY_BUFFER, obj.vertexBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, obj.vertexBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, obj.textureBuffer
    @gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, obj.textureBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.activeTexture @gl.TEXTURE0
    @gl.bindTexture @gl.TEXTURE_2D, obj.texture
    @gl.uniform1i @gl.getUniformLocation(@shaderProgram, "uSampler"), 0

    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, obj.indexBuffer

    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, @pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, @mvMatrix

    @gl.drawElements @gl.TRIANGLES, obj.indexBuffer.numItems, @gl.UNSIGNED_SHORT, 0

    @mvPopMatrix()

  renderFrame: ->
    that = @
    requestAnimFrame -> that.renderFrame()
    @handleKeys()
    @drawScene()

  playerObject: ->
    @objects[@controlled_object_index]

  handleKeyDown: (event) ->
    @pressedKeys[event.keyCode] = true

  handleKeyUp: (event) ->
    delete @pressedKeys[event.keyCode] if @pressedKeys && @pressedKeys[event.keyCode]

  handleKeys: ->
    return if !(@pressedKeys[37] || @pressedKeys[38] || @pressedKeys[39] || @pressedKeys[40])

    position = @playerObject().position
    angle = @playerObject().angle

    distance = 0.1
    #z -= 0.05 if @pressedKeys[32] # fire (space)

    angle += 5 if @pressedKeys[37] # left
    angle -= 5 if @pressedKeys[39] # right
    if @pressedKeys[38] # up
      x = distance * Math.cos(@degToRad(angle)) + position[0]
      y = distance * Math.sin(@degToRad(angle)) + position[1]
      position = [x, y]
    if @pressedKeys[40] # down
      x = - distance * Math.cos(@degToRad(angle)) + position[0]
      y = - distance * Math.sin(@degToRad(angle)) + position[1]
      position = [x, y]

    @playerObject().move(position, angle)