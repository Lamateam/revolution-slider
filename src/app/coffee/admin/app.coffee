define "admin/app", [ 
  "marionette"
], (Marionette)->
  app = Marionette.Application.extend
    onStart: ->
      require [ "admin/router" ], (Router)->
        new Router()
        Backbone.history.start()
        