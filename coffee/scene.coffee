class window.Scene
  constructor: ->
    @scene = new THREE.Scene()
    @frameID = null

    @worldSize = 15

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    @camera.position.set(0, 2, 0)

    @lat = 0
    @lon = 0
    @phi = 0
    @theta = 0

    @mouse = new THREE.Vector2()
    @intersected = null
    @intersectedFace = null
    @raycaster = new THREE.Raycaster()

    @push =
      left: false
      right: false
      up: false
      down: false

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

      @push.left = event.clientX < (window.innerWidth * 0.3)
      @push.right = event.clientX > (window.innerWidth * 0.7)
      @push.up = event.clientY < (window.innerHeight * 0.2)
      @push.down = event.clientY > (window.innerHeight * 0.8)

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

  translateCamera: (distance, isX) ->
    # Try the movement and revert if it would move us into a block.
    x = @camera.position.x
    y = @camera.position.y
    z = @camera.position.z

    if isX
      @camera.translateX(distance)
    else
      @camera.translateZ(distance)

    # Revert if hitting a block.
    if @isBlocked(x: @camera.position.x, y: @camera.position.y, z: @camera.position.z)
      @camera.position.set(x, y, z)
    else
      # Don't let translations move up/down or go off the map
      @camera.position.x = Math.min(@camera.position.x, @worldSize)
      @camera.position.x = Math.max(@camera.position.x, -@worldSize)
      @camera.position.y = y
      @camera.position.z = Math.min(@camera.position.z, @worldSize)
      @camera.position.z = Math.max(@camera.position.z, -@worldSize)

  move: =>
    step = 0.25
    diagStep = step / Math.sqrt(2)
    jumpStep = step / 2

    switch @direction
      when Dir.S
        @translateCamera(step, false)
      when Dir.SE
        @translateCamera(diagStep, true)
        @translateCamera(diagStep, false)
      when Dir.W
        @translateCamera(-step, true)
      when Dir.NW
        @translateCamera(-diagStep, true)
        @translateCamera(-diagStep, false)
      when Dir.N
        @translateCamera(-step, false)
      when Dir.NE
        @translateCamera(diagStep, true)
        @translateCamera(-diagStep, false)
      when Dir.E
        @translateCamera(step, true)
      when Dir.SW
        @translateCamera(-diagStep, true)
        @translateCamera(diagStep, false)

    # If jumping, move up a little and decrement frames.
    if @jumping
      @camera.position.y += jumpStep
      @jumpFramesLeft--
      @jumping = (@jumpFramesLeft > 0)

    # If not jumping, check for gravity
    unless @jumping
      loc = @currentLocation()
      loc.y = loc.y - 2
      unless @cubeAt(loc)
        @camera.position.y -= jumpStep

    # Push camera if mouse near screen edge
    if @push.left
      @lon -= 5
    if @push.right
      @lon += 5
    if @push.up
      @lat += 3
    if @push.down
      @lat -= 3

    # Update camera lookat
    @lat = Math.max(-85, Math.min(85, @lat))
    @phi = (90 - @lat) * Math.PI / 180
    @theta = @lon * Math.PI / 180

    targetPosition = new THREE.Vector3(0, 0, 0)
    targetPosition.x = @camera.position.x + 100 * Math.sin(@phi) * Math.cos(@theta)
    targetPosition.y = @camera.position.y + 100 * Math.cos(@phi)
    targetPosition.z = @camera.position.z + 100 * Math.sin(@phi) * Math.sin(@theta)

    @camera.lookAt(targetPosition)

    setTimeout(@move, 25)

  histLocation: (loc) ->
    {
      x: Math.round(loc.x)
      y: Math.round(loc.y)
      z: Math.round(loc.z)
    }

  currentLocation: ->
    {
      x: @camera.position.x
      y: @camera.position.y
      z: @camera.position.z
    }

  isBlocked: (loc) ->
    @cubeAt(loc) || @cubeAt(x: loc.x, y: loc.y - 1, z: loc.z)

  cubeAt: (loc) ->
    loc = @histLocation(loc)
    @cubes[loc.x] && @cubes[loc.x][loc.y] && @cubes[loc.x][loc.y][loc.z]