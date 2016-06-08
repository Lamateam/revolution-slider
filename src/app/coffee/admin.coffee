require.config
  baseUrl: 'static/js/'
  paths:
    "underscore": "modules/underscore"
    "backbone": "modules/backbone"
    "marionette": "modules/marionette"
    "jquery": "modules/jquery"
    "jquery-ui": "modules/jquery-ui"
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

window.Behaviors = {}
require [ "overwrites/behaviors", "overwrites/controller" ], ->
  require [ "admin/app" ], (App)->
    window.App = new App()
    window.App.start()
