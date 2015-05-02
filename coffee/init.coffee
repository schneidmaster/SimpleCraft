# Create and render scene.
scene = new Scene()
scene.render()

# Bindings
$(window).on 'click', ->
  scene.togglePause()