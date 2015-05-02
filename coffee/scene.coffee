class window.Scene
  constructor: ->
    @scene = new THREE.Scene()
    @frameID = null

    @worldSize = 15

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    @camera.position.set(0, 2, 0)
    @camera.lookAt(x: 0, y: -2, z: 7)

    @mouse = new THREE.Vector2()
    @intersected = null
    @intersectedFace = null
    @raycaster = new THREE.Raycaster()

    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    @renderer.setClearColor(0x7EC0EE, 1)

    document.body.appendChild(@renderer.domElement)

    @direction = Dir.NONE
    @jumping = false
    @jumpFramesLeft = 0

    # Set up world.
    @cubes = {}
    for x in [-@worldSize..@worldSize]
      @cubes[x] = {}
      @cubes[x][0] = {}
      for z in [-@worldSize..@worldSize]
        loc = { x: x, y: 0, z: z }
        @cubes[x][0][z] = new Cube(@scene, CubeTypes.CONCRETE, loc)

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
      if event.shiftKey
        if @intersected.cube.isDirt()
          x = @intersected.position.x
          y = @intersected.position.y
          z = @intersected.position.z
          @intersected.cube.destroy()
          @cubes[x][y][z] = null

      else
        x = @intersected.position.x
        y = @intersected.position.y
        z = @intersected.position.z

        switch @intersectedFace
          when FaceDir.WEST then x++
          when FaceDir.EAST then x--
          when FaceDir.TOP then y++
          when FaceDir.SOUTH then z--

        @cubes[x][y] ?= {}
        loc = { x: x, y: y, z: z }
        @cubes[x][y][z] = new Cube(@scene, CubeTypes.DIRT, loc)

    # Initiate movement loop.
    setTimeout(@move, 25)  

  render: =>
    @raycaster.setFromCamera(@mouse, @camera)
    intersects = @raycaster.intersectObjects(@scene.children)

    if intersects.length > 0
      intersectObj = intersects[0].object
      intersectFace = Math.floor(intersects[0].faceIndex / 2)
      unless @intersected == intersectObj && @intersectedFace == intersectFace
        @intersected.cube.unhighlight() if @intersected
        @intersected = intersectObj
        @intersectedFace = intersectFace
        @intersected.cube.highlight(@intersectedFace)
    else if @intersected
      @intersected.cube.unhighlight()
      @intersected = null

    @frameID = requestAnimationFrame(@render)
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
      unless @cubeAt(loc)
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
    @cubeAt(loc)

  cubeAt: (loc) ->
    loc = @histLocation(loc)
    @cubes[loc.x] && @cubes[loc.x][loc.y] && @cubes[loc.x][loc.y][loc.z]