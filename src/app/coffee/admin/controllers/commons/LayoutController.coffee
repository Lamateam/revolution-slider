define "controllers/commons/LayoutController", [ 
  "marionette"
  "views/commons/LayoutView"
  "controllers/home/LayoutController"
], (Marionette, LayoutView, HomeLayoutController)->
  LayoutController = Marionette.Controller.extend
    home: ->
      @options.subcontroller = new HomeLayoutController() if !(@options.subcontroller instanceof HomeLayoutController)
      @options.subcontroller.hello()
    home_new_blanc_project: ->
      @options.subcontroller = new HomeLayoutController() if !(@options.subcontroller instanceof HomeLayoutController)
      @options.subcontroller.new_blanc_project()
    initialize: ->
      @options.regionManager = new Marionette.RegionManager
        regions:
          main: "#main"

      @options.layout = new LayoutView()

      @getOption('regionManager').get('main').show @getOption('layout')
