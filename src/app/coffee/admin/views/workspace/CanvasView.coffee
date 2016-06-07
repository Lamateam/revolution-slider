define "views/workspace/CanvasView", [ 
  "marionette"
], (Marionette)->
  CanvasItem = Marionette.View.extend
    fillStyle: (color)->
      @getOption("ctx").fillStyle = color
    fillRect: ->
      console.log "here 2"
      @getOption("ctx").fillRect @model.get("x"), @model.get("y"), @model.get("width"), @model.get("height")
    render: ->
      t = @model.get "type"

      @fillStyle @model.get "color"

      switch
        when t is "fill_rect" then @fillRect()

  CanvasView = Marionette.View.extend
    tagName: "canvas"
    onShow: ->
      console.log "here", @collection
      canvas = @el
      ctx    = canvas.getContext "2d"

      canvas.width  = @getOption "width"
      canvas.height = @getOption "height"

      ctx.clearRect 0, 0, canvas.width, canvas.height

      @collection.each (model)->
        console.log model.toJSON()
        new CanvasItem({model: model, ctx: ctx}).render()

    # buildChildView: (model, ChildView)->
    #   ctx = @el.getContext "2d"
    #   t   = model.get "type"

    #   ctx.fillStyle = model.get "color"

    #   switch
    #     when t is "fill_rect" then @renderFillRect ctx, model

    #   new ChildView()

