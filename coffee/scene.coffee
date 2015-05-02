class window.Scene
  constructor: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)
    document.body.appendChild(@renderer.domElement)

    @frameID = null
    @pause = true

    geometry = new THREE.BoxGeometry(0.1, 0.1, 0.1)
    material = new THREE.MeshLambertMaterial(
      map: THREE.ImageUtils.loadTexture('textures/dirt.png')
    )

    @cubes = []

    lastOne = true

    # Set up 31x31x31 world.
    for x in [-15..15]
      for y in [-33..-2]
        for z in [-15..15]
          cube = new THREE.Mesh(geometry, material)
          @scene.add(cube)
          cube.translateX(x)
          cube.translateY(y)
          cube.translateZ(z)

    @camera.position.z = 5

  togglePause: ->
    @pause = !@pause
    if @pause
      cancelAnimationFrame(@frameID)
    else
      @render()

  render: =>
    @pause = false
    @frameID = requestAnimationFrame(@render)
    @renderer.render(@scene, @camera)