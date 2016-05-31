define "controllers/home/LayoutController", [ 
  "marionette"
  "views/home/LayoutView"
], (Marionette, HomeLayoutView)->
  HomeLayoutController = Marionette.Controller.extend
    hello: ->
      @getOption('layout').showHello()
    new_blanc_project: ->
      @getOption('layout').showNewBlancProject()
    new_template_project: ->
      @getOption('layout').showNewTemplateProject()
    initialize: ->
      @options.regionManager = new Marionette.RegionManager
        regions:
          content: "#content"

      @options.layout = new HomeLayoutView()

      @getOption('regionManager').get('content').show @getOption('layout')
