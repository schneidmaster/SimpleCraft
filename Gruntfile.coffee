module.exports = (grunt) ->
  grunt.initConfig
    pkg: '<json:package.json>'

    # Compile CoffeeScript to JavaScript.
    coffee:
      compile:
        files:
          '.tmp/scene.js': 'coffee/scene.coffee'
          '.tmp/init.js': 'coffee/init.coffee'

    # Concat application JavaScript with three.js into one file.
    concat:
      dist:
        src: [
          'bower_components/threejs/build/three.min.js'
          'bower_components/jquery/dist/jquery.min.js'
          '.tmp/scene.js'
          '.tmp/init.js'
        ]
        dest: 'build/application.js'

    # Remove temp directory,
    clean: ['.tmp']

    # Recompile whenever CoffeeScript is updated.
    watch:
      scripts:
        files: ['coffee/scene.coffee', 'coffee/init.coffee']
        tasks: ['default']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.registerTask 'default', ['coffee', 'concat', 'clean']