define "views/workspace/CanvasView", [ 
  "marionette"
  "libs/helpers"
  "templates/workspace/canvas"
  "d3"
], (Marionette, Helpers, CanvasTemplate)->
  html = d3.select 'html'
  CanvasItem = Marionette.ItemView.extend
    tagName: "g"
    canResize: true
    canMove: true
    id: ->
      "element_" + @model.get "id"
    _createElement: (tagName)->
      @d3_el.remove() if @d3_el isnt undefined
      svg        = d3.select(@options.svg)
      dimensions = svg.node().getBBox()
      @d3_el     = svg.append(tagName)

      @options.parentX = dimensions.x
      @options.parentY = dimensions.y

      @d3_el.node()
    _removeElement: ()->
      @$el.remove()
      @d3_el.remove() if @d3_el isnt undefined
    _setAttributes: (attributes)->
      @d3_el.data attributes
      @d3_el.attr "stroke-width", 2
      @d3_el.attr "stroke-opacity", 0.3
      @d3_el.attr key, value for own key, value of attributes
    template: ->
      "some stuff"
    modelEvents:
      "sync": "render"
    setActive: ->
      colors = Helpers.invertRGB @options.node.attr("fill")
      prefix = if colors.length is 3 then 'rgb' else 'rgba'
      @d3_el.attr "stroke", prefix + '(' + colors.join(",") + ')'

      @initResize(@options.node) if @canResize
    setInactive: ->
      @d3_el.attr "stroke", "transparent"
      @destroyResize()
    attachElContent: ->
      props  = @model.get("props")
      width  = if props.width then props.width else props.r
      height = if props.height then props.height else props.r

      @options.node = @d3_el.append @model.get("type") if @options.node is undefined
      @options.node.attr key, value for own key, value of props
      @setActive() if @getOption("stateModel").get("isElementSelected") is @model.get("id")

      @initDnD @options.node if @canMove
      @initEvents @options.node
    initEvents: (n)->
      id = @model.get 'id'
      n.on "click", ->
        return if d3.event.defaultPrevented
        window.App.trigger "element:click", { id: id }
      @listenTo @getOption("stateModel"), "change:isElementSelected", @onSomeElementSelected
    onSomeElementSelected: ->
      if @getOption("stateModel").get("isElementSelected") is @model.get("id") then @setActive() else @setInactive()
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

      drag = d3.behavior.drag()

      dragInitiated = false
      timeout       = null

      drag.on "dragstart", =>
        button = d3.event.sourceEvent.button
        timeout = setTimeout ()=>
          if button is 0
            @destroyResize() if @getOption("stateModel").get("isElementSelected") is @model.get("id")
            n.style "opacity", 0.5
            dragInitiated = true
        , 150

      drag.on "drag", ->
        if dragInitiated
          n.attr x_val, d3.event.x - width*0.5
          n.attr y_val, d3.event.y - height*0.5

      drag.on "dragend", =>
        clearTimeout timeout
        if dragInitiated and d3.event.sourceEvent.button is 0
          d3.event.sourceEvent.stopPropagation()
          timeout = null
          n.style "opacity", 1
          dragInitiated = false

          @initResize(n) if @getOption("stateModel").get("isElementSelected") is @model.get("id")

          data = 
            el: id
            props: {}
          data.props[x_val] = n.attr(x_val) - old_x
          data.props[y_val] = n.attr(y_val) - old_y
          window.App.trigger "element:move", data

      n.call drag
    createDot: (x, y, moveHandler)->
      dot  = @d3_el.append("circle").classed("dot", true).attr("r", 3).attr("fill", @model.get("props").fill).attr("cx", x).attr("cy", y)
      type = @model.get 'type'
      id   = @model.get 'id'
      node = @options.node
      dot.on "mousedown", ->
        return if d3.event.defaultPrevented
        html.on 'mousemove', =>
          coords = d3.mouse @
          moveHandler coords[0], coords[1]
        html.on 'mouseup', ->
          props = if type is 'circle' then { cx: parseInt(node.attr('cx'), 10), cy: parseInt(node.attr('cy'), 10), r: parseInt(node.attr('r'), 10) } else { x: parseInt(node.attr('x'), 10), y: parseInt(node.attr('y'), 10), width: parseInt(node.attr('width'), 10), height: parseInt(node.attr('height'), 10) }
          window.App.trigger "element:resize", { el: id, props: props }
          html.on 'mousemove', null
          html.on 'mouseup', null
    moveDots: ->
      dimensions = @options.node.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5

      @options.top_dot.attr('cx', x_center).attr('cy', dimensions.y) if @options.top_dot isnt undefined
      @options.bottom_dot.attr('cx', dimensions.x + dimensions.width*0.5).attr('cy', dimensions.y + dimensions.height) if @options.bottom_dot isnt undefined
      @options.right_dot.attr('cx', dimensions.x + dimensions.width).attr('cy', y_center) if @options.right_dot isnt undefined
      @options.left_dot.attr('cx', dimensions.x).attr('cy', y_center) if @options.left_dot isnt undefined
    initResize: (n)->
      @destroyResize()

      dimensions = n.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5
      type       = @model.get 'type'

      @options.top_dot    = @createDot x_center, dimensions.y, (x, y)=>
        new_d = if type is "circle" then parseInt(n.attr('cy'), 10) - y else parseInt(n.attr('height'), 10) + parseInt(n.attr('y'), 10) - y
        if new_d > 20
          if type is "circle" then n.attr("r", new_d) else n.attr('height', new_d).attr('y', y)        
          @moveDots()
      @options.bottom_dot = @createDot x_center, dimensions.y + dimensions.height, (x, y)=>
        new_d = if type is "circle" then y - parseInt(n.attr('cy'), 10) else y - parseInt(n.attr('y'), 10)
        if new_d > 20
          if type is "circle" then n.attr("r", new_d) else n.attr('height', new_d).attr('y', y - new_d)        
          @moveDots()
      @options.right_dot  = @createDot dimensions.x + dimensions.width, y_center, (x, y)=>
        new_d = if type is "circle" then x - parseInt(n.attr('cx'), 10) else x - parseInt(n.attr('x'), 10)
        if new_d > 20  
          if type is "circle" then n.attr("r", new_d) else n.attr('width', new_d).attr('x', x - new_d)        
          @moveDots()   
      @options.left_dot    = @createDot dimensions.x, y_center, (x, y)=>
        new_d = if type is "circle" then parseInt(n.attr('cx'), 10) - x else parseInt(n.attr('width'), 10) + parseInt(n.attr('x'), 10) - x
        if new_d > 20
          if type is "circle" then n.attr("r", new_d) else n.attr('width', new_d).attr('x', x)        
          @moveDots()   
        
    destroyResize: ->
      @d3_el.selectAll('.dot').remove()
      @options.top_dot    = undefined
      @options.bottom_dot = undefined
      @options.left_dot   = undefined
      @options.right_dot  = undefined

  CanvasView = Marionette.CompositeView.extend
    childView: CanvasItem
    childViewContainer: "svg"
    modelEvents:
      'change:name': 'render'
    events:
      'click .bind-slide-edit': 'onSlideEditClick'
    childViewOptions: ->
      res = 
        stateModel: @options.stateModel
        svg: @el.getElementsByTagName("svg")[0]
    attachHtml: (collectionView, childView, index)->
      console.log "Here junk attachHtml"
    templateHelpers: ->
      res = 
        width: @options.width
        height: @options.height
    template: CanvasTemplate
    onSlideEditClick: ->
      window.App.trigger "slide:select", { id: @model.get 'id' }

