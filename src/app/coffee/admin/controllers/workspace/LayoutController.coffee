define "controllers/workspace/LayoutController", [ 
  "marionette"
  "models/ProjectModel"
  "models/SlideModel"
  "models/WorkspaceStateModel"
  "collections/HistoryCollection"
  "collections/ElementsCollection"
  "views/workspace/LayoutView"
], (Marionette, ProjectModel, SlideModel, WorkspaceStateModel, HistoryCollection, ElementsCollection, WorkspaceLayoutView)->
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
      @listenTo window.App, "element:click", @onElementClick
      @listenTo window.App, "element:resize", @onElementResize
      @listenTo window.App, "element:change", @onElementChange

      @listenTo window.App, "slide:change", @onSlideChange
      @listenTo window.App, "slide:select", @onSlideSelect

      Marionette.LayoutController.prototype.initialize.apply @
    renderTopPanel: ->
      @getOption('layout').renderTopPanel
        model: @getOption 'projectModel'
        stateModel: @getOption 'stateModel'
        historyCollection: @getOption 'historyCollection'
    renderCanvas: (slide)->
      c = @getOption('elementsCollection')
      c.reset slide.get 'elements'

      @getOption('layout').renderCanvas
        collection: c
        width: 500
        height: 500
        model: slide
        stateModel: @getOption 'stateModel'
    renderRightPanel: (model, type)->
      @getOption('layout').renderRightPanel
        model: model
        type: type
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
          when "resize", "change" then @changeElement el, options.previous
          when "change_slide" then @changeSlide options.previous

    onWorkspaceRedo: ->
      if @getOption('historyCollection').canRedo()
        console.log "redo"
        model   = @getOption('historyCollection').redo()
        action  = model.get 'action'
        el      = model.get 'el'
        options = model.get 'options'

        switch action
          when "move" then @moveElement el, options
          when "resize", "change" then @changeElement el, options.current
          when "change_slide" then @changeSlide options.current
    onWorkspaceDownload: ->

    onWorkspacePreview: ->

    onProjectUpdate: (obj)->
      @getOption('projectModel').save obj, 
        success: =>
          @getOption('stateModel').clearStates()
        wait: true
        patch: true
    moveElement: (el, data)->
      model = @getOption('elementsCollection').findWhere { id: el }
      props = model.get 'props'
      props[key] = props[key] + value for key, value of data
      model.save { props: props }, { wait: true, patch: true }
    changeElement: (el, data)->
      model = @getOption('elementsCollection').findWhere { id: el }
      props = model.get 'props'
      props[key] = value for key, value of data
      model.save { props: props }, { wait: true, patch: true }  
    changeSlide: (data)->
      @getOption('slideModel').save data, { wait: true, patch: true }        
    onElementMove: (data)->
      @getOption('historyCollection').addAction { action: "move", el: data.el, options: data.props }
      @getOption('stateModel').setState "isElementSelected", data.el
      @moveElement data.el, data.props
    onElementClick: (data)->
      @getOption('stateModel').setState "isElementSelected", data.id
      model = @getOption('elementsCollection').findWhere { id: data.id }
      @renderRightPanel model, 'element'
    onElementResize: (data)->
      model = @getOption('elementsCollection').findWhere { id: data.el }
      @getOption('historyCollection').addAction { action: "resize", el: data.el, options: {current: data.props, previous: _.clone(model.get('props')) } }
      @changeElement data.el, data.props
    onElementChange: (data)->
      console.log data
      model = @getOption('elementsCollection').findWhere { id: data.el }
      @getOption('historyCollection').addAction { action: "change", el: data.el, options: {current: data.props, previous: _.clone(model.get('props')) } }
      @changeElement data.el, data.props      
    onSlideChange: (data)->
      console.log data
      @getOption('historyCollection').addAction { action: "change_slide", options: {current: data, previous: @getOption('slideModel').toJSON() } }
      @changeSlide data
    onSlideSelect: (data)->
      console.log data
    openSlide: ->
      @options.slideModel            = new SlideModel @getOption('projectModel').get('slides')[@slide]
      @options.slideModel.project_id = @getOption('projectModel').get 'id'

      @renderCanvas @options.slideModel
      @renderRightPanel @options.slideModel, 'slide'
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
      
