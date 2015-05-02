class window.Scene
  constructor: ->
    @scene = new THREE.Scene()

    @worldSize = 15

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    @camera.position.set(0, 2, 0)
    @camera.lookAt(x: 0, y: -2, z: 7)

    @mouse = new THREE.Vector2()
    @intersected = null
    @raycaster = new THREE.Raycaster()

    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @renderer.setClearColor(0x7EC0EE, 1)

    document.body.appendChild(@renderer.domElement)

    @direction = Dir.NONE
    @jumping = false
    @jumpFramesLeft = 0

    @geometry = new THREE.BoxGeometry(1, 1, 1)

    # Set up 31x31x31 world.
    @cubes = {}
    for x in [-@worldSize..@worldSize]
      @cubes[x] = {}
      # -(@worldSize * 2)
      for y in [-1..0]
        @cubes[x][y] = {}
        for z in [-@worldSize..@worldSize]
          @addCube(x, y, z)

    # Bind movement events
    $(window).on 'keydown', (event) =>
      # Update direction based on keypress.
      @direction = switch
        when event.which is Keys.LEFT
          switch
            when @direction is Dir.NONE then Dir.W
            when @direction is Dir.N then Dir.NW
            when @direction is Dir.NE then Dir.N
            when @direction is Dir.E then Dir.NONE
            when @direction is Dir.SE then Dir.S
            when @direction is Dir.S then Dir.SW
            else @direction
        when event.which is Keys.UP
          switch
            when @direction is Dir.NONE then Dir.N
            when @direction is Dir.E then Dir.NE
            when @direction is Dir.SE then Dir.E
            when @direction is Dir.S then Dir.NONE
            when @direction is Dir.SW then Dir.W
            when @direction is Dir.W then Dir.NW
            else @direction
        when event.which is Keys.RIGHT
          switch
            when @direction is Dir.NONE then Dir.E
            when @direction is Dir.N then Dir.NE
            when @direction is Dir.NW then Dir.N
            when @direction is Dir.W then Dir.NONE
            when @direction is Dir.SW then Dir.S
            when @direction is Dir.S then Dir.SE
            else @direction
        when event.which is Keys.DOWN
          switch
            when @direction is Dir.NONE then Dir.S
            when @direction is Dir.E then Dir.SE
            when @direction is Dir.NE then Dir.E
            when @direction is Dir.N then Dir.NONE
            when @direction is Dir.NW then Dir.W
            when @direction is Dir.W then Dir.SW
            else @direction
        when event.which is Keys.SPACE
          # Indicate we are jumping
          unless @jumping
            @jumping = true
            @jumpFramesLeft = 8

          # Keep moving same XZ direction
          @direction
        else @direction

    $(window).on 'keyup', (event) =>
      # Update direction based on key release.
      @direction = switch
        when event.which is Keys.LEFT
          switch
            when @direction is Dir.SW then Dir.S
            when @direction is Dir.W then Dir.NONE
            when @direction is Dir.NW then Dir.N
            else @direction
        when event.which is Keys.UP
          switch
            when @direction is Dir.N then Dir.NONE
            when @direction is Dir.NE then Dir.E
            when @direction is Dir.NW then Dir.W
            else @direction
        when event.which is Keys.RIGHT
          switch
            when @direction is Dir.NE then Dir.N
            when @direction is Dir.E then Dir.NONE
            when @direction is Dir.SE then Dir.S
            else @direction
        when event.which is Keys.DOWN
          switch
            when @direction is Dir.SE then Dir.E
            when @direction is Dir.S then Dir.NONE
            when @direction is Dir.SW then Dir.W
            else @direction
        else @direction

    # Bind mouse move/click
    $(window).on 'mousemove', (event) =>
      event.preventDefault()

      @mouse.x = (event.clientX / window.innerWidth) * 2 - 1
      @mouse.y = -(event.clientY / window.innerHeight) * 2 + 1

    $(window).on 'click', (event) =>
      return unless @intersected
      pos = @intersected.position
      cube = @cubes[pos.x][pos.y][pos.z]

      @cubes[pos.x][pos.y + 1] ?= {}
      @addCube(pos.x, pos.y + 1, pos.z)

    # Initiate movement loop.
    setTimeout(@move, 25)  

  addCube: (x, y, z) =>
    cube = new THREE.Mesh(@geometry, Materials.DIRT)
    @scene.add(cube)
    cube.translateX(x)
    cube.translateY(y)
    cube.translateZ(z)
    @cubes[x][y][z] =
      mesh: cube
      solid: true

  render: =>
    @raycaster.setFromCamera(@mouse, @camera)
    intersects = @raycaster.intersectObjects(@scene.children)

    if intersects.length > 0
      unless @intersected == intersects[0].object
        @intersected.material = Materials.DIRT if @intersected
        @intersected = intersects[0].object
        @intersected.material = Materials.LIGHTDIRT
    else if @intersected
      @intersected.material = Materials.DIRT
      @intersected = null

    requestAnimationFrame(@render)
    @renderer.render(@scene, @camera)

  move: =>
    step = 0.25
    diagStep = step / Math.sqrt(2)
    jumpStep = step / 2

    switch @direction
      when Dir.S
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z - step)
          @camera.position.z = Math.max(@camera.position.z - step, -@worldSize)
      when Dir.SE
        unless @isBlocked(x: @camera.position.x - diagStep, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.max(@camera.position.x - diagStep, -@worldSize)
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z - diagStep)
          @camera.position.z = Math.max(@camera.position.z - diagStep, -@worldSize)
      when Dir.W
        unless @isBlocked(x: @camera.position.x + step, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.min(@camera.position.x + step, @worldSize)
      when Dir.NW
        unless @isBlocked(x: @camera.position.x + diagStep, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.min(@camera.position.x + diagStep, @worldSize)
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z + diagStep)
          @camera.position.z = Math.min(@camera.position.z + diagStep, @worldSize)
      when Dir.N
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z + step)
          @camera.position.z = Math.min(@camera.position.z + step, @worldSize)
      when Dir.NE
        unless @isBlocked(x: @camera.position.x - diagStep, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.max(@camera.position.x - diagStep, -@worldSize)
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z + diagStep)
          @camera.position.z = Math.min(@camera.position.z + diagStep, @worldSize)
      when Dir.E
        unless @isBlocked(x: @camera.position.x - step, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.max(@camera.position.x - step, -@worldSize)
      when Dir.SW
        unless @isBlocked(x: @camera.position.x + diagStep, y: @camera.position.y, z: @camera.position.z)
          @camera.position.x = Math.min(@camera.position.x + diagStep, @worldSize)
        unless @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z - diagStep)
          @camera.position.z = Math.max(@camera.position.z - diagStep, -@worldSize)

    # If jumping, move up a little and decrement frames.
    if @jumping
      @camera.position.y += jumpStep
      @jumpFramesLeft--
      @jumping = (@jumpFramesLeft > 0)

    # If not jumping, check for gravity
    unless @jumping
      loc = @currentLocation()
      loc.y = Math.max(loc.y - 1, -@worldSize)
      unless @isSolid(loc)
        @camera.position.y -= jumpStep

    setTimeout(@move, 25)

  histLocation: (loc) ->
    loc.x =
      if loc.x < 0
        Math.ceil(loc.x)
      else
        Math.floor(loc.x)
    loc.y =
      if loc.y < 0
        Math.ceil(loc.y)
      else
        Math.floor(loc.y)
    loc.z =
      if loc.z < 0
        Math.ceil(loc.z)
      else
        Math.floor(loc.z)
    loc

  currentLocation: ->
    {
      x: @camera.position.x
      y: @camera.position.y
      z: @camera.position.z
    }

  isBlocked: (loc) ->
    @isSolid(loc)# || @isSolid(x: loc.x, y: loc.y - 1, z: loc.z)

  isSolid: (loc) ->
    loc = @histLocation(loc)
    if @cubes[loc.x] != undefined && @cubes[loc.x][loc.y] != undefined && 
    @cubes[loc.x][loc.y][loc.z] != undefined
      @cubes[loc.x][loc.y][loc.z].solid

# Directions Enum for movement
Dir =
  NONE: 0
  N: 1
  NE: 2
  E: 3
  SE: 4
  S: 5
  SW: 6
  W: 7
  NW: 8

# Keys Enum for detection
Keys =
  LEFT: 65
  UP: 87
  RIGHT: 68
  DOWN: 83
  SPACE: 32

Textures =
  DIRT: THREE.ImageUtils.loadTexture('textures/dirt.png')
  LIGHTDIRT: THREE.ImageUtils.loadTexture('textures/lightdirt.png')

Materials =
  DIRT: new THREE.MeshBasicMaterial(map: Textures.DIRT, side: THREE.DoubleSide)
  LIGHTDIRT: new THREE.MeshBasicMaterial(map: Textures.LIGHTDIRT, side: THREE.DoubleSide)