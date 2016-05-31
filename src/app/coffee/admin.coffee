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
    "text": "require_plugins/text"
    "templates": "../html/admin"
  shim:
    "libs/api": 
      deps: [ "jquery" ]
      exports: "LamaApi"
    "underscore":
      exports: "_"
    "jade":
      exports: "jade"
    "backbone":
      deps: [ "underscore", "jquery" ]
      exports: "Backbone"
    "marionette":
      deps: [ "backbone", "modules/backbone.babysitter", "modules/backbone.wreqr" ]
      exports: "Marionette"

define "admin", [ "admin/app" ], (App)->
  Marionette.TemplateCache.prototype.loadTemplate = (templateId, options)->
    $template = Backbone.$(templateId)

    if !$template.length
      $template = 
        html: ->
          jade.compile templateId, options

    $template.html()
  new App().start()