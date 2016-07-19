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
      modules_images:
        files: [
          {
            src: "node_modules/malihu-custom-scrollbar-plugin/mCSB_buttons.png"
            dest: "dist/images/mCSB_buttons.png"
          }
        ]        
      modules:
        files: [
          {
            src: "node_modules/jquery/dist/jquery.js"
            dest: "tmp/modules/jquery.js"            
          }
          {
            src: "node_modules/jquery-ui/jquery-ui.js"
            dest: "tmp/modules/jquery-ui.js"            
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
          {
            src: "node_modules/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.js"
            dest: "tmp/modules/jquery.mCustomScrollbar.js"
          }
          {
            src: "node_modules/jquery-mousewheel/jquery.mousewheel.js"
            dest: "tmp/modules/jquery.mousewheel.js"
          }
          {
            src: "node_modules/d3/d3.js"
            dest: "tmp/modules/d3.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/vendor/jquery.ui.widget.js"
            dest: "tmp/modules/jquery.ui.widget.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.iframe-transport.js"
            dest: "tmp/modules/jquery.iframe-transport.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload.js"
            dest: "tmp/modules/jquery.fileupload.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-ui.js"
            dest: "tmp/modules/jquery.fileupload-ui.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-image.js"
            dest: "tmp/modules/jquery.fileupload-image.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-audio.js"
            dest: "tmp/modules/jquery.fileupload-audio.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-video.js"
            dest: "tmp/modules/jquery.fileupload-video.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-validate.js"
            dest: "tmp/modules/jquery.fileupload-validate.js"
          }
          {
            src: "node_modules/blueimp-file-upload/js/jquery.fileupload-process.js"
            dest: "tmp/modules/jquery.fileupload-process.js"
          }
          {
            src: "node_modules/blueimp-tmpl/js/tmpl.js"
            dest: "tmp/modules/tmpl.js"
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
          optimize: 'none'
          findNestedDependencies: true
          inlineText: true
          mainConfigFile: './tmp/admin.js'
          keepBuildDir: true   
    "regex-replace":  
      mCSB:
        src: [ "./dist/style.css" ]
        actions: [
          {
            name: "mCSB"
            search: "mCSB_buttons.png"
            replace: "/static/images/mCSB_buttons.png"
            flags: "gi"
          }
        ]
    concat:
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
          "node_modules/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.css"
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
      client:
        files:
          "dist/client.css": "src/app/stylus/client.styl"
    coffee:
      app:
        expand: true
        cwd: 'src/app/coffee'
        src: ['**/*.coffee']
        dest: 'tmp'
        ext: '.js'    
        extDot: 'last'
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
      styles:
        files: ["src/app/**/*.*"]
        tasks: ["compile-styles-short"]
      vendor:
        files: ["vendor/**/*.*"]
        tasks: ["compile-test"]
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
  grunt.loadNpmTasks 'grunt-regex-replace'

  # Default task.
  grunt.registerTask "compile-scripts", [ "coffee" ]
  grunt.registerTask "compile-styles", ["stylus", "concat:vendor_css", "concat:css", "regex-replace"]
  grunt.registerTask "compile-development", ["clean:tmp", "clean:dist", "compile-scripts", "compile-styles", "copy", "mkdir", "clean:tmp"]
  grunt.registerTask "compile-release", ["compile-development", "uglify:js", "cssmin"]
  
  grunt.registerTask "compile-test", [ "clean:tmp", "clean:dist", "copy", "compile-scripts", "requirejs:compile_dev", "compile-styles", "mkdir" ]

  grunt.registerTask "compile-styles-short", ["compile-styles", "cssmin", "clean:tmp", "watch:styles"]

  grunt.registerTask "start-development", ["compile-development", "shell:start", "watch"]  
  grunt.registerTask "start", ["compile-release", "shell:start"]