class window.Scene
  constructor: ->
    @scene = new THREE.Scene()
    @worldSize = 15

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    @camera.position.set(0, 0, 0)
    @camera.lookAt(@scene.position)

    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @renderer.setClearColor(0x7EC0EE, 1)

    document.body.appendChild(@renderer.domElement)

    @direction = Dir.NONE
    @jumping = false
    @jumpFramesLeft = 0

    geometry = new THREE.BoxGeometry(1, 1, 1)
    material = new THREE.MeshBasicMaterial(
      map: THREE.ImageUtils.loadTexture('textures/dirt.png')
      side: THREE.DoubleSide
    )

    # Set up 31x31x31 world.
    @cubes = {}
    for x in [-@worldSize..@worldSize]
      @cubes[x] = {}
      for y in [-(@worldSize * 2 + 3)..-2]
        @cubes[x][y] = {}
        for z in [-@worldSize..@worldSize]
          cube = new THREE.Mesh(geometry, material)
          @scene.add(cube)
          cube.translateX(x)
          cube.translateY(y)
          cube.translateZ(z)
          @cubes[x][y][z] =
            mesh: cube
            solid: true

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



    setTimeout(@move, 25)  

  render: =>
    requestAnimationFrame(@render)
    @renderer.render(@scene, @camera)

  move: =>
    step = 0.25
    diagStep = step / Math.sqrt(2)
    jumpStep = step / 2

    switch @direction
      when Dir.N then @camera.position.z = Math.max(@camera.position.z - step, -@worldSize)
      when Dir.NW
        @camera.position.x = Math.max(@camera.position.x - diagStep, -@worldSize)
        @camera.position.z = Math.max(@camera.position.z - diagStep, -@worldSize)
      when Dir.E then @camera.position.x = Math.min(@camera.position.x + step, @worldSize)
      when Dir.SE
        @camera.position.x = Math.min(@camera.position.x + diagStep, @worldSize)
        @camera.position.z = Math.min(@camera.position.z + diagStep, @worldSize)
      when Dir.S then @camera.position.z = Math.min(@camera.position.z + step, @worldSize)
      when Dir.SW
        @camera.position.x = Math.max(@camera.position.x - diagStep, -@worldSize)
        @camera.position.z = Math.min(@camera.position.z + diagStep, @worldSize)
      when Dir.W then @camera.position.x = Math.max(@camera.position.x - step, -@worldSize)
      when Dir.NE
        @camera.position.x = Math.min(@camera.position.x + diagStep, @worldSize)
        @camera.position.z = Math.max(@camera.position.z - diagStep, -@worldSize)

    # If jumping, move up a little and decrement frames.
    if @jumping
      @camera.position.y += jumpStep
      @jumpFramesLeft--
      @jumping = (@jumpFramesLeft > 0)

    # If not jumping, check for gravity
    unless @jumping
      loc = @currentLocation()
      loc.y = Math.max(loc.y - 2, -@worldSize)
      unless @isSolid(loc)
        @camera.position.y -= jumpStep

    setTimeout(@move, 25)

  currentLocation: ->
    x =
      if @camera.position.x > 0
        Math.ceil(@camera.position.x)
      else
        Math.floor(@camera.position.x)
    y =
      if @camera.position.y > 0
        Math.ceil(@camera.position.y)
      else
        Math.floor(@camera.position.y)
    z =
      if @camera.position.z > 0
        Math.ceil(@camera.position.z)
      else
        Math.floor(@camera.position.z)
    {
      x: x
      y: y
      z: z
    }

  isSolid: (loc) ->
    @cubes[loc.x] != undefined && @cubes[loc.x][loc.y] != undefined && 
    @cubes[loc.x][loc.y][loc.z] != undefined && @cubes[loc.x][loc.y][loc.z].solid

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
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40
  SPACE: 32