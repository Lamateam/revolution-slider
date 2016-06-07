define "controllers/workspace/LayoutController", [ 
  "marionette"
  "models/ProjectModel"
  "collections/ElementsCollection"
  "views/workspace/LayoutView"
], (Marionette, ProjectModel, ElementsCollection, WorkspaceLayoutView)->
  WorkspaceLayoutController = Marionette.LayoutController.extend
    Layout: WorkspaceLayoutView
    renderTopPanel: ->
      @getOption('layout').renderTopPanel
        model: @getOption('projectModel')
    renderCanvas: ->
      c = new ElementsCollection()
      c.add {type: "fill_rect", color: "#ff0000", x: 10, y: 10, width: 100, height: 100}
      @getOption('layout').renderCanvas
        collection: c
        width: 500
        height: 500
    openProject: (id)->
      @options.projectModel = new ProjectModel {id: id, dim: ""}
      @listenTo @getOption('projectModel'), "change:name", @renderTopPanel
      @listenTo @getOption('projectModel'), "change:dim", @renderCanvas

      @getOption('projectModel').fetch()
      
