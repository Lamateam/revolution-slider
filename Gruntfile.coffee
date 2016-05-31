# Grunt configuration updated to latest Grunt.  That means your minimum
# version necessary to run these tasks is Grunt 0.4.
#
# Please install this locally and install `grunt-cli` globally to run.
module.exports = (grunt) ->
  
  # Initialize the configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    shell:
      start:
        command: "coffee server.coffee"
    clean: 
      tmp: ["tmp"]
      dist: ["dist"]
    copy:
      vendor:
        files: [
          {expand: true, cwd: 'vendor/', src: [ 'fonts/**/*.*', 'images/**/*.*' ], dest: 'dist/'}
        ]
      vendor_js:
        files: [
          {expand: true, cwd: 'vendor/', src: [ '*.js' ], dest: 'tmp/vendor'}
        ]
      html_tmp:
        files: [
          {expand: true, cwd: 'src/app/html/', src: [ '**/*.html', '**/*.jade' ], dest: 'tmp/html'}
        ]
      html_dist:
        files: [
          {expand: true, cwd: 'src/app/html/', src: [ '**/*.html', '**/*.jade' ], dest: 'dist/html'}
        ]        
      modules:
        files: [
          {
            src: "node_modules/jquery/dist/jquery.js"
            dest: "tmp/modules/jquery.js"            
          }
          {
            src: "node_modules/jquery-knob/dist/jquery.knob.min.js"
            dest: "tmp/modules/jquery.knob.js"            
          }
          {
            src: "node_modules/bootstrap/dist/js/bootstrap.js"
            dest: "tmp/modules/bootstrap.js"            
          }
          {
            src: "node_modules/sweetalert/dist/sweetalert.min.js"
            dest: "tmp/modules/sweetalert.js" 
          }
          {
            src: "node_modules/backbone/backbone.js"
            dest: "tmp/modules/backbone.js"
          }
          {
            src: "node_modules/backbone.babysitter/lib/backbone.babysitter.js"
            dest: "tmp/modules/backbone.babysitter.js"
          }
          {
            src: "node_modules/backbone.marionette/lib/backbone.marionette.js"
            dest: "tmp/modules/backbone.marionette.js"
          }
          {
            src: "node_modules/backbone.wreqr/lib/backbone.wreqr.js"
            dest: "tmp/modules/backbone.wreqr.js"
          }  
          {
            src: "node_modules/underscore/underscore.js"
            dest: "tmp/modules/underscore.js"
          }
          {
            src: "node_modules/backbone.marionette/lib/backbone.marionette.js"
            dest: "tmp/modules/marionette.js"
          }  
          {
            src: "node_modules/jade/jade.js"
            dest: "tmp/modules/jade.js"
          }      
        ]
      requirejs: 
        files: [
          {
            src: "node_modules/requirejs/require.js"
            dest: "dist/require.js"
          }
          {
            src: "node_modules/text/text.js"
            dest: "tmp/require_plugins/text.js"
          }
          {
            src: "vendor/require.jade.js"
            dest: "tmp/jadeRuntime.js"
          }
          {
            src: "vendor/require.jade.js"
            dest: "dist/js/jadeRuntime.js"
          }
        ]
      bootstrap_fonts:
        files: [
          {expand: true, cwd: 'node_modules/bootstrap/dist/fonts/', src: ['**'], dest: 'dist/fonts'}
        ]
    requirejs:
      compile:
        options:
          appDir: "./tmp/"
          baseUrl: "."
          dir: "dist/js"
          name: "admin"
          findNestedDependencies: true
          inlineText: true
          mainConfigFile: './tmp/admin.js'
          keepBuildDir: true
      compile_dev:
        options:
          appDir: "./tmp/"
          baseUrl: "."
          dir: "dist/js"
          findNestedDependencies: true
          inlineText: true
          mainConfigFile: './tmp/admin.js'
          keepBuildDir: true        
    concat:
      fileupload:
        src: [
          "node_modules/blueimp-file-upload/js/jquery.fileupload.js"
          "node_modules/blueimp-file-upload/js/jquery.fileupload-ui.js"
          "node_modules/blueimp-file-upload/js/jquery.iframe-transport.js"
        ]
        dest: "tmp/modules/fileupload.js"
      vendor_css:
        src: [
          "vendor/animate.css"
          "vendor/jquery-ui.min.css"
        ]
        dest: "tmp/vendor.css"
      css:
        src: [
          "node_modules/bootstrap/dist/css/bootstrap.css"
          "node_modules/sweetalert/dist/sweetalert.css"
          "node_modules/blueimp-file-upload/css/jquery.fileupload.css"
          "node_modules/blueimp-file-upload/css/jquery.fileupload-ui.css"
          "tmp/vendor.css"
          "tmp/style.css"
        ]
        dest: "dist/style.css"
    stylus:
      app:
        options:
          define:
            import_tree: require 'stylus-import-tree'
            font_face: require 'stylus-font-face'
        files:
          "tmp/style.css": "src/app/stylus/style.styl"
    coffee:
      app:
        expand: true
        cwd: 'src/app/coffee'
        src: ['**/*.coffee']
        dest: 'tmp'
        ext: '.js'    
    uglify:
      js:
        files:
          "dist/script.min.js": ["dist/script.js"]
    cssmin:
      target:
        files:
          "dist/style.min.css": ["dist/style.css"]
    watch:
      main:
        files: ["src/app/**/*.*"]
        tasks: ["compile-development"]
    mkdir:
      all:
        options:
          mode: 777
          create: ['dist/files']

  # Load external Grunt task plugins.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-mkdir'
  grunt.loadNpmTasks 'grunt-shell'

  # Default task.
  grunt.registerTask "compile-scripts", [ "coffee", "concat:fileupload" ]
  grunt.registerTask "compile-styles", ["stylus", "concat:vendor_css", "concat:css"]
  grunt.registerTask "compile-development", ["clean:tmp", "clean:dist", "compile-scripts", "compile-styles", "copy", "mkdir", "clean:tmp"]
  grunt.registerTask "compile-release", ["compile-development", "uglify:js", "cssmin"]
  
  grunt.registerTask "compile-test", [ "clean:tmp", "clean:dist", "copy", "compile-scripts", "requirejs:compile_dev", "compile-styles", "mkdir" ]

  grunt.registerTask "start-development", ["compile-development", "shell:start", "watch"]  
  grunt.registerTask "start", ["compile-release", "shell:start"]