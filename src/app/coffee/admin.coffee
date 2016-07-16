require.config
  baseUrl: 'static/js/'
  paths:
    "underscore": "modules/underscore"
    "backbone": "modules/backbone"
    "marionette": "modules/marionette"
    "jquery": "modules/jquery"
    "jquery-ui": "modules/jquery-ui"
    "jscolor": "vendor/jscolor"
    "ddslick": "vendor/ddslick"
    "controllers": "admin/controllers"
    "views": "admin/views"
    "models": "admin/models"
    "collections": "admin/collections"
    "behaviors": "admin/behaviors"
    "overwrites": "admin/overwrites"
    "text": "require_plugins/text"
    "templates": "../html/admin"
    "mCSB": "modules/jquery.mCustomScrollbar"
    "SweetAlert": "modules/sweetalert"
    "d3": "modules/d3"
    "jquery.fileupload": "modules/jquery.fileupload"
    "jquery.fileupload-ui": "modules/jquery.fileupload-ui"
    "jquery.fileupload-image": "modules/jquery.fileupload-image"
    "jquery.fileupload-video": "modules/jquery.fileupload-video"
    "jquery.fileupload-audio": "modules/jquery.fileupload-audio"
    "jquery.fileupload-validate": "modules/jquery.fileupload-validate"
    "jquery.fileupload-process": "modules/jquery.fileupload-process"
    "jquery.ui.widget": "modules/jquery.ui.widget"
    "jquery.iframe-transport": "modules/jquery.iframe-transport"
    "tmpl": "modules/tmpl"
    "load-image": "vendor/load-image"
    "load-image-meta": "vendor/load-image-meta"
    "load-image-exif": "vendor/load-image-exif"
    "canvas-to-blob": "vendor/canvas-to-blob"
  shim:
    "libs/api": 
      deps: [ "jquery" ]
      exports: "LamaApi"
    "underscore":
      exports: "_"
    "backbone":
      deps: [ "underscore", "jquery" ]
      exports: "Backbone"
    "marionette":
      deps: [ "backbone", "modules/backbone.babysitter", "modules/backbone.wreqr" ]
      exports: "Marionette"
    "mCSB":
      deps: [ "jquery", "modules/jquery.mousewheel" ]
    "SweetAlert":
      deps: [ "jquery" ]
    "jquery-ui":
      deps: [ "jquery" ]
    "ddslick": 
      deps: [ "jquery" ]
    "jquery.iframe-transport":
      deps: [ "jquery" ]
    "jquery.fileupload-ui":
      deps: [ "jquery" ]
    "jquery.ui.widget":
      deps: [ "jquery" ]

window.Behaviors = {}
require [ "overwrites/behaviors", "overwrites/controller", "overwrites/views" ], ->
  require [ "admin/app" ], (App)->
    window.App = new App()
    window.App.start()
