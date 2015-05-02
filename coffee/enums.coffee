# Directions Enum for movement
window.Dir =
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
window.Keys =
  LEFT: 65
  UP: 87
  RIGHT: 68
  DOWN: 83
  SPACE: 32

window.Textures =
  DIRT: THREE.ImageUtils.loadTexture('textures/dirt.png')
  LIGHTDIRT: THREE.ImageUtils.loadTexture('textures/lightdirt.png')
  CONCRETE: THREE.ImageUtils.loadTexture('textures/concrete.png')
  LIGHTCONCRETE: THREE.ImageUtils.loadTexture('textures/lightconcrete.png')

window.Materials =
  DIRT: 
    REGULAR: new THREE.MeshBasicMaterial(map: Textures.DIRT, side: THREE.DoubleSide)
    LIGHT: new THREE.MeshBasicMaterial(map: Textures.LIGHTDIRT, side: THREE.DoubleSide)
  CONCRETE:
    REGULAR: new THREE.MeshBasicMaterial(map: Textures.CONCRETE, side: THREE.DoubleSide)
    LIGHT: new THREE.MeshBasicMaterial(map: Textures.LIGHTCONCRETE, side: THREE.DoubleSide)

window.FaceDir =
  WEST: 0
  EAST: 1
  TOP: 2
  SOUTH: 5

window.CubeTypes =
  DIRT: 1
  CONCRETE: 2
