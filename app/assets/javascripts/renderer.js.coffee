@App.Renderer =
  renderer: null
  scene: null
  camera: null
  keyboard: null
  clock: null

  objects: {}
  current_player_id: 0

  playerObject: ->
    @objects[@current_player_id]

  init: ->
    @clock = new THREE.Clock()

    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 1, 1000
    @camera.position.z = 400
    @camera.position.x = 0
    @camera.position.y = 0

    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize window.innerWidth, window.innerHeight
    document.body.appendChild @renderer.domElement

    that = @
    window.addEventListener 'resize', ->
      that.resize()
      return
    , false

    @keyboard = new THREEx.KeyboardState()

    @drawScene()

    @render()

  resize: ->
    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()
    @renderer.setSize window.innerWidth, window.innerHeight

    return

  drawScene: ->
    that = @

    # axis helper
    axis_helper = new THREE.AxisHelper 200
    axis_helper.position.set 0, 0, 0
    @scene.add axis_helper

    # light
    light = new THREE.PointLight 0xffffff
    light.position.set 0, 0, 250
    light.castShadow = true
    @scene.add light

    lightbulb = new THREE.Mesh(new THREE.SphereGeometry(2, 8, 4), new THREE.MeshBasicMaterial color: 0xffaa00)
    @scene.add lightbulb
    lightbulb.position = light.position

    # ambient light
    a_light = new THREE.AmbientLight 0x444444
    @scene.add a_light

    # ground
    floor_texture  = THREE.ImageUtils.loadTexture '/assets/Grass_6.png', {}, ->
      that.render()
    floor_texture.wrapS = floor_texture.wrapT = THREE.RepeatWrapping
    floor_texture.repeat.set 3, 3

    floor = new THREE.Mesh new THREE.PlaneGeometry(800, 800), new THREE.MeshLambertMaterial(map: floor_texture)
    @scene.add floor

    #texture
    texture = THREE.ImageUtils.loadTexture '/assets/models/tank.jpg', {}, ->
      that.render()
    texture.anisotropy = @renderer.getMaxAnisotropy()

    # model
    loader = new THREE.JSONLoader()
    loader.load '/assets/models/tank.json', (model) ->
      that.addGameObject 0, model, texture, [0, 0, 50] #current player
      that.addGameObject 1, model, texture, [300, -180, 50], -Math.PI / 2 #dummy
      that.addGameObject 1, model, texture, [-200, 200, 50], Math.PI / 3 #dummy
      return

    return

  addGameObject: (id, obj, texture, position, rotation) ->
    @objects[id] = @addModelToScene obj, texture, position, rotation

  addModelToScene: (object, texture, position, rotation) ->
    material = new THREE.MeshLambertMaterial(if texture then map: texture else color: 0x00ff00)
    mesh = new THREE.Mesh object, material
    mesh.position.set position[0], position[1], position[2]
    mesh.rotation.y = rotation if rotation
    mesh.scale.set 10, 10, 10
    mesh.rotation.x = Math.PI / 2
    @scene.add mesh
    mesh

  render: ->
    that = @
    requestAnimationFrame -> that.render()
    @renderer.render @scene, @camera
    @update()

    return

  update: ->
    delta = @clock.getDelta()
    moveDistance = 150 * delta

    if @keyboard.pressed "down"
      @playerObject().translateX moveDistance
    if @keyboard.pressed("up")
      @playerObject().translateX -moveDistance
    if @keyboard.pressed("left")
      @playerObject().rotation.y += delta * 2
    if @keyboard.pressed("right")
      @playerObject().rotation.y -= delta * 2

    return