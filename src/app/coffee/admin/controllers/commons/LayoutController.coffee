define "controllers/commons/LayoutController", [ 
  "marionette"
  "views/commons/LayoutView"
  "controllers/home/LayoutController"
  "controllers/workspace/LayoutController"
], (Marionette, LayoutView, HomeLayoutController, WorkspaceLayoutController)->
  LayoutController = Marionette.Controller.extend
    goToHello: ->
      Backbone.history.navigate "home/hello", {trigger: true}
    home_hello: ->
      @getOption('homeController').renderLayout()
      @getOption('homeController').hello()
    home_new_blanc_project: ->
      @getOption('homeController').renderLayout()
      @getOption('homeController').new_blanc_project()
    home_new_template_project: ->
      @getOption('homeController').renderLayout()
      @getOption('homeController').new_template_project()
    workspace: (id)->
      @getOption('workspaceController').renderLayout()
      @getOption('workspaceController').openProject id
    initialize: ->
      @options.regionManager = new Marionette.RegionManager
        regions:
          main: "#main"

      @options.layout = new LayoutView()

      @getOption('regionManager').get('main').show @getOption('layout')

      @options.homeController = new HomeLayoutController()
      @options.workspaceController = new WorkspaceLayoutController()

