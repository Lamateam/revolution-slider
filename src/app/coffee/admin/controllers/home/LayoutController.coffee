define "controllers/home/LayoutController", [ 
  "marionette"
  "models/ProjectModel"
  "views/home/LayoutView"
], (Marionette, ProjectModel, HomeLayoutView)->
  HomeLayoutController = Marionette.LayoutController.extend
    Layout: HomeLayoutView
    onProjectCreate: (data)->
      @getOption('projectModel').save data,
        wait: true
        success: (model)->
          Backbone.history.navigate "workspace/" + model.get("id"), {trigger: true}     
    initialize: ->
      @options.projectModel = new ProjectModel()
      @listenTo window.App, "project:create", @onProjectCreate
      Marionette.LayoutController.prototype.initialize.apply @
    hello: ->
      @getOption('layout').showHello()
    new_blanc_project: ->
      @getOption('layout').showNewBlancProject
        model: @getOption('projectModel')
    new_template_project: ->
      @getOption('layout').showNewTemplateProject()
