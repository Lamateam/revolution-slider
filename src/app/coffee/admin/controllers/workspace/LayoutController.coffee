define "controllers/workspace/LayoutController", [ 
  "marionette"
  "models/ProjectModel"
  "models/WorkspaceStateModel"
  "collections/HistoryCollection"
  "collections/ElementsCollection"
  "views/workspace/LayoutView"
], (Marionette, ProjectModel, WorkspaceStateModel, HistoryCollection, ElementsCollection, WorkspaceLayoutView)->
  WorkspaceLayoutController = Marionette.LayoutController.extend
    Layout: WorkspaceLayoutView
    initialize: ->
      @options.projectModel       = new ProjectModel { id: -1 }
      @options.stateModel         = new WorkspaceStateModel()
      @options.historyCollection  = new HistoryCollection()
      @options.elementsCollection = new ElementsCollection()

      @listenTo window.App, "workspace:name", @onWorkspaceName
      @listenTo window.App, "workspace:undo", @onWorkspaceUndo
      @listenTo window.App, "workspace:redo", @onWorkspaceRedo
      @listenTo window.App, "workspace:download", @onWorkspaceDownload
      @listenTo window.App, "workspace:preview", @onWorkspacePreview
      @listenTo window.App, "project:update", @onProjectUpdate
      @listenTo window.App, "element:move", @onElementMove

      Marionette.LayoutController.prototype.initialize.apply @
    renderTopPanel: ->
      @getOption('layout').renderTopPanel
        model: @getOption('projectModel')
        stateModel: @getOption('stateModel')
    renderCanvas: (elements)->
      c = @getOption('elementsCollection')
      c.reset elements

      @getOption('layout').renderCanvas
        collection: c
        width: 500
        height: 500
    onWorkspaceName: ->
      @getOption('stateModel').setState "isNameChange"
    onWorkspaceUndo: ->
      if @getOption('historyCollection').canUndo()
        console.log "undo"
        model   = @getOption('historyCollection').undo()
        action  = model.get 'action'
        el      = model.get 'el'
        options = model.get 'options'

        switch action
          when "move"
            data = {}
            data[key] = -value for own key, value of options
            @moveElement el, data

    onWorkspaceRedo: ->
      if @getOption('historyCollection').canRedo()
        console.log "redo"
        model   = @getOption('historyCollection').redo()
        action  = model.get 'action'
        el      = model.get 'el'
        options = model.get 'options'

        switch action
          when "move"
            @moveElement el, options
    onWorkspaceDownload: ->

    onWorkspacePreview: ->

    onProjectUpdate: (obj)->
      @getOption('projectModel').save obj, 
        success: =>
          @getOption('stateModel').clearStates()
    moveElement: (el, data)->
      model = @getOption('elementsCollection').findWhere { id: el }
      props = model.get 'props'
      props[key] = props[key] + value for key, value of data
      model.save { props: props }, { wait: true }
    onElementMove: (data)->
      @getOption('historyCollection').addAction { action: "move", el: data.el, options: data.props }
      @moveElement data.el, data.props
    openSlide: ->
      slide = @getOption('projectModel').get('slides')[@slide]
      @renderCanvas slide.elements
    openProject: (id, @slide)->
      projectModel       = @getOption('projectModel')
      elementsCollection = @getOption('elementsCollection')

      elementsCollection.project_id = id
      elementsCollection.slide_id   = @slide

      @getOption('historyCollection').addAction { action: "open_slide", el: @slide, options: {} }

      if projectModel.get("id") isnt id
        projectModel.set { id: id, dim: "" }

        @listenTo projectModel, "change:name", _.once @renderTopPanel
        @listenTo projectModel, "change:dim", _.once @openSlide

        projectModel.fetch()
      else 
        @openSlide()
      
