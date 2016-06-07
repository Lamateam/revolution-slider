define "overwrites/controller", [ "marionette" ], (Marionette)->
  Marionette.LayoutController = Marionette.Controller.extend
    renderLayout: ->
      @getOption('regionManager').get('content').show @getOption('layout')
    initialize: ->
      @options.regionManager = new Marionette.RegionManager
        regions:
          content: "#content"

      @options.layout = new @Layout