class window.Cube
  constructor: (@scene, @type, @loc) ->
    @materialBase =
      if @isDirt()
        Materials.DIRT.REGULAR
      else
        Materials.CONCRETE.REGULAR
    @materialLight =
      if @isDirt()
        Materials.DIRT.LIGHT
      else
        Materials.CONCRETE.LIGHT
    @material = 
      new THREE.MeshFaceMaterial([
        @materialBase
        @materialBase
        @materialBase
        @materialBase
        @materialBase
        @materialBase
      ])
    @obj = new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1), @material)
    @obj.cube = @
    @lightenedFace = null

    @scene.add(@obj)
    @obj.translateX(@loc.x)
    @obj.translateY(@loc.y)
    @obj.translateZ(@loc.z)

  isDirt: ->
    @type == CubeTypes.DIRT

  highlight: (face) ->
    unless @lightenedFace
      @lightenedFace = face
      @material.materials[@lightenedFace] = @materialLight

  unhighlight: ->
    @material.materials[@lightenedFace] = @materialBase
    @lightenedFace = null

  destroy: ->
    @scene.remove(@obj)
