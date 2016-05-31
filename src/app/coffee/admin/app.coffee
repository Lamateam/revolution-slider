define "admin/app", [ 
  "marionette"
  "admin/router"
], (Marionette, Router, Layout)->
  app = Marionette.Application.extend
    onStart: ->
      new Router()
      Backbone.history.start()
        