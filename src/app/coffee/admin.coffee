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
    "text": "require_plugins/text"
    "templates": "../html/admin"
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

define "admin", [ "admin/app" ], (App)->
  new App().start()