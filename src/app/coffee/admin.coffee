require.config
  baseUrl: 'static/js/'
  paths:
    "underscore": "modules/underscore"
    "backbone": "modules/backbone"
    "marionette": "modules/marionette"
    "jquery": "modules/jquery"
    "controllers": "admin/controllers"
    "views": "admin/views"
    "models": "admin/models"
    "collections": "admin/collections"
    "behaviors": "admin/behaviors"
    "overwrites": "admin/overwrites"
    "text": "require_plugins/text"
    "templates": "../html/admin"
    "mCSB": "modules/jquery.mCustomScrollbar"
    "SweatAlert": "modules/sweetalert"
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
    "SweatAlert":
      deps: ["jquery"]

define "admin", [ "admin/app" ], (App)->
  new App().start()