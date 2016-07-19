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
      @listenTo window.App, "slide:update", @onSlideChange

      @listenTo window.App, "element:move", @onElementMove
      @listenTo window.App, "element:click", @onElementClick
      @listenTo window.App, "element:resize", @onElementResize
      @listenTo window.App, "element:change", @onElementChange
      @listenTo window.App, "element:create", @onElementCreate
      @listenTo window.App, "element:reorder", @onElementReOrder

      @listenTo window.App, "slide:change", @onSlideChange
      @listenTo window.App, "slide:select", @onSlideSelect

      @listenTo window.App, "image:create", @onImageCreate
      @listenTo window.App, "image:edit", @onImageEdit
      @listenTo window.App, "image:url_upload", @onImageUrlUpload

      @listenTo window.App, "animation:add", @onAnimationAdd
      @listenTo window.App, "animation:change", @onAnimationChange
      @listenTo window.App, "animations:change", @onAnimationsChange

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
    renderLeftPanel: ->
      @getOption('layout').renderLeftPanel
        model: @getOption('projectModel')
        elements: @getOption('elementsCollection')
    onWorkspaceName: ->
      @getOption('stateModel').clearState "isElementSelected"
      @renderRightPanel @getOption('projectModel'), 'project'      
    onWorkspaceUndo: ->
      if @getOption('historyCollection').canUndo()
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
          @renderTopPanel()
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
      @renderRightPanel @getOption('elementsCollection').findWhere({ id: data.el }), 'element'
    onElementClick: (data)->
      @getOption('stateModel').setState "isElementSelected", data.id
      model = @getOption('elementsCollection').findWhere { id: data.id }
      @renderRightPanel model, 'element'
    onElementResize: (data)->
      model = @getOption('elementsCollection').findWhere { id: data.el }
      @getOption('historyCollection').addAction { action: "resize", el: data.el, options: {current: data.props, previous: _.clone(model.get('props')) } }
      @changeElement data.el, data.props
    onElementChange: (data)->
      model = @getOption('elementsCollection').findWhere { id: data.el }
      @getOption('historyCollection').addAction { action: "change", el: data.el, options: {current: data.props, previous: _.clone(model.get('props')) } }
      @changeElement data.el, data.props      
    onElementCreate: (data)->
      elementsCollection = @getOption 'elementsCollection'
      ids                = elementsCollection.pluck 'id'

      data.order = if elementsCollection.last() then elementsCollection.last().get('order') + 1 else 0
      data.id    = if ids.length is 0 then 0 else Math.max.apply(null, ids) + 1

      elementsCollection.addElement data
    onElementReOrder: (data)->
      model = @getOption('elementsCollection').findWhere { id: data.el }
      model.save { order: data.order }, { patch: true, wait: true }
    onSlideChange: (data)->
      @getOption('historyCollection').addAction { action: "change_slide", options: {current: data, previous: @getOption('slideModel').toJSON() } }
      @changeSlide data
    onSlideSelect: (data)->
      @getOption('stateModel').clearState "isElementSelected"
      @renderRightPanel @options.slideModel, 'slide'
    onImageCreate: ->
      @getOption('layout').renderUploadImage()
    onImageEdit: (data)->
      @getOption('layout').renderUploadEditImage data
    onImageUrlUpload: (_data)->
      $.ajax
        url: '/api/images/upload/url'
        method: 'POST'
        contentType: "application/json"
        data: JSON.stringify _data
        success: (data)->
          if _data.id isnt undefined
            window.App.trigger "element:change", { el: _data.id, props: { "xlink:href": data.url } }
          else
            window.App.trigger "element:create", { type: "image", props: { x: 100, y: 100, angle: 0, width: 170, height: 200, fill: "rgb(0,0,0)", "xlink:href": data.fileName } }
    onAnimationAdd: (data)->
      switch data.element.type
        when 'slide'
          animations = @getOption('slideModel').get 'animations'
          animations.push data.model.toJSON()
          @changeSlide { animations: animations }
        when 'element'
          model = @getOption('elementsCollection').findWhere { id: data.element.id }
          animations = model.get 'animations'
          animations.push data.model.toJSON()
          model.save { animations: animations }, { wait: true, patch: true } 
    onAnimationChange: (data)->
      switch data.element.type
        when 'slide'
          animations = @getOption('slideModel').get 'animations'

          for animation in animations
            console.log 'diff: ', animation.id, data.id
            if animation.id is data.id
              animation[key] = value for own key, value of data.data

          @changeSlide { animations: animations }
        when 'element'
          model = @getOption('elementsCollection').findWhere { id: data.element.id }
          animations = model.get 'animations'

          for animation in animations
            console.log 'diff: ', animation.id, data.id
            if animation.id is data.id
              animation[key] = value for own key, value of data.data  

          model.save { animations: animations }, { wait: true, patch: true } 
          window.App.trigger 'element:' + model.get('id') + ':animation:change', { animations: animations }  
    onAnimationsChange: (data)->
      console.log 'data: ', data
      switch data.element.type
        when 'slide'
          animations = @getOption('slideModel').get 'animations'
          for a in data.animations
            is_new = true

            for animation in animations
              if animation.id is a.id
                animation[key] = value for own key, value of a.data
                is_new         = false

            animations.push a if is_new

          @changeSlide { animations: animations }
        when 'element'
          model = @getOption('elementsCollection').findWhere { id: data.element.id }
          animations = model.get 'animations'
          for a in data.animations
            is_new = true

            for animation in animations
              if animation.id is a.id
                animation[key] = value for own key, value of a.data  
                is_new         = false

            animations.push a if is_new

          model.save { animations: animations }, { wait: true, patch: true, success: => @renderRightPanel model, 'element' }               
          
          window.App.trigger 'element:' + model.get('id') + ':animation:change', { animations: animations }
    openSlide: ->
      @options.slideModel            = new SlideModel @getOption('projectModel').get('slides')[@slide]
      @options.slideModel.project_id = @getOption('projectModel').get 'id'

      @listenTo @options.slideModel, 'sync', ->
        @renderRightPanel @options.slideModel, 'slide'

      @renderCanvas @options.slideModel
      @renderRightPanel @options.slideModel, 'slide'
      @renderLeftPanel()
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
      
