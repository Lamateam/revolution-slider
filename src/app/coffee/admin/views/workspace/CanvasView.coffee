define "views/workspace/CanvasView", [ 
  "marionette"
  "templates/workspace/canvas"
  "d3"
], (Marionette, CanvasTemplate)->
  CanvasItem = Marionette.ItemView.extend
    tagName: "g"
    id: ->
      "element_" + @model.get "id"
    _createElement: (tagName)->
      @d3_el.remove() if @d3_el isnt undefined
      @d3_el = d3.select(@options.svg).append(tagName)
      @d3_el.node()
    _removeElement: ()->
      @$el.remove()
      @d3_el.remove() if @d3_el isnt undefined
    _setAttributes: (attributes)->
      @d3_el.data attributes
      @d3_el.attr key, value for own key, value of attributes
    template: ->
      "some stuff"
    modelEvents:
      "sync": "render"
    attachElContent: ->
      props  = @model.get("props")
      width  = if props.width then props.width else props.r
      height = if props.height then props.height else props.r

      @options.node = @d3_el.append @model.get("type") if @options.node is undefined
      @options.node.attr key, value for own key, value of props

      @initDnD @options.node
      @initEvents @options.node
    initEvents: (n)->
      n.on "click", ->
        return if d3.event.defaultPrevented

        console.log "clicked"
    initDnD: (n)->
      props  = @model.get "props"
      t      = @model.get "type"

      width  = if props.width isnt undefined then props.width else 0
      height = if props.height isnt undefined then props.height else 0

      x_val  = if t is "circle" then "cx" else "x"
      y_val  = if t is "circle" then "cy" else "y"

      id     = @model.get "id"
      old_x  = n.attr x_val
      old_y  = n.attr y_val
      console.log id, old_y, old_x

      drag = d3.behavior.drag()

      dragInitiated = false
      timeout       = null

      drag.on "dragstart", ->
        button = d3.event.sourceEvent.button
        timeout = setTimeout ->
          if button is 0
            n.style "opacity", 0.5
            dragInitiated = true
        , 150

      drag.on "drag", ->
        if dragInitiated
          n.attr x_val, d3.event.x - width*0.5
          n.attr y_val, d3.event.y - height*0.5

      drag.on "dragend", ->
        if d3.event.sourceEvent.button is 0
          if timeout then clearTimeout(timeout) else d3.event.sourceEvent.stopPropagation()
          timeout = null
          n.style "opacity", 1
          dragInitiated = false

          data = 
            el: id
            props: {}
          data.props[x_val] = n.attr(x_val) - old_x
          data.props[y_val] = n.attr(y_val) - old_y
          window.App.trigger "element:move", data

      n.call drag

  CanvasView = Marionette.CompositeView.extend
    childView: CanvasItem
    childViewContainer: "svg"
    childViewOptions: ->
      res = 
        svg: @el.getElementsByTagName("svg")[0]
    attachHtml: (collectionView, childView, index)->
      console.log "Here junk attachHtml"
    templateHelpers: ->
      res = 
        width: @options.width
        height: @options.height
    template: CanvasTemplate

