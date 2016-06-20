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
      type   = @model.get 'type'

      @options.node = @d3_el.append type if @options.node is undefined
      @setNodeAttribute(@options.node, key, value) for own key, value of props

      @canResize = false if type is 'text'
      
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

      setCenter = (x, y)->
        dimensions = n.node().getBBox()
        n.attr 'x', x - dimensions.width*0.5
        n.attr 'y', y - dimensions.height*0.5

      drag.on "dragstart", =>
        button = d3.event.sourceEvent.button
        timeout = setTimeout ()=>
          if button is 0
            @destroyResize() if @getOption("stateModel").get("isElementSelected") is @model.get("id")
            n.style "opacity", 0.5
            dragInitiated = true
        , 150

      drag.on "drag", =>
        if dragInitiated
          setCenter d3.event.x, d3.event.y
          # # console.log d3.event.x, d3.event.y
          # n.attr x_val, d3.event.x - width*0.5
          # n.attr y_val, d3.event.y - height*0.5
          # # @setNodeAttribute n, 'angle', props.angle
          # @d3_el.attr 'transform', 'rotate(' + props.angle + ',' + d3.event.x + ',' + d3.event.y + ')'

      drag.on "dragend", =>
        clearTimeout timeout
        if dragInitiated and d3.event.sourceEvent.button is 0
          d3.event.sourceEvent.stopPropagation()
          timeout = null
          n.style "opacity", 1
          dragInitiated = false

          @initResize(n) if @canResize and @getOption("stateModel").get("isElementSelected") is @model.get("id")

          data = 
            el: id
            props: {}
          data.props[x_val] = parseFloat n.attr(x_val), 10
          data.props[y_val] = parseFloat n.attr(y_val), 10
          console.log data.props
          window.App.trigger "element:change", data

      n.call drag
    setNodeAttribute: (node, key, value)->
      center_x = if @model.get('type') is 'circle' then @model.get('props').cx else @model.get('props').x+@model.get('props').width*0.5
      center_y = if @model.get('type') is 'circle' then @model.get('props').cy else @model.get('props').y+@model.get('props').height*0.5
      switch 
        when key is 'text' then node.text value
        when key is 'angle' 
          props = @model.get 'props'
          console.log 'center props: ', props
          w2    = props.width*0.5
          h2    = props.height*0.5
          sin   = Math.sin value
          cos   = Math.cos value
          @d3_el.attr 'transform', 'rotate(' + value + ',' + (props.x+w2) + ',' + (props.y+h2) + ')'
        when true then node.attr key, value
    moveDots: ->
      dimensions = @options.node.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5

      @options.dots.data([
        { x: x_center, y: dimensions.y, name: 'n' }
        { x: dimensions.x + dimensions.width, y: y_center, name: 'e' }
        { x: dimensions.x + dimensions.width, y: dimensions.y, name: 'ne' }
        { x: dimensions.x, y: dimensions.y, name: 'nw' }
      ], (d)->
        d.name
      ).attr('cx', (d)->
        d.x
      ).attr('cy', (d)->
        d.y
      )
    initResize: (n)->
      @destroyResize()

      dimensions = n.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5
      type       = @model.get 'type'
      props      = @model.get 'props'
      node       = @options.node

      drag = d3.behavior.drag()
      drag.on 'drag', (d)=>
        x          = d3.event.x
        y          = d3.event.y
        dimensions = n.node().getBBox()
        x_center   = dimensions.x + dimensions.width*0.5
        y_center   = dimensions.y + dimensions.height*0.5

        console.log x_center, y_center, dimensions.x, dimensions.y

        new_d = Math.sqrt Math.pow( y - y_center, 2 ) + Math.pow( x - x_center, 2 )
        console.log 'new dim: ', new_d, ', x_center: ', x_center, y_center
        switch d.name
          when 'n'
            dh = new_d*2 - dimensions.height
            @setNodeAttribute n, 'height', new_d*2
            console.log 'dh: ', dh

            @setNodeAttribute n, 'y', dimensions.y - dh*0.5
          when 'ne', 'nw'
            if (x isnt x_center) or (y isnt y_center)
              props.angle = props.angle + (180 / Math.PI) * Math.atan2(y - y_center, x - x_center)
              dalpha      = (180 / Math.PI) * Math.atan(dimensions.width / dimensions.height)
              console.log dalpha
              props.angle = props.angle + 90 - dalpha if d.name is 'ne'
              props.angle = props.angle + dalpha + 90 if d.name is 'nw'
              @setNodeAttribute n, 'angle', props.angle

        @moveDots()

      drag.on 'dragend', =>
        props = if type is 'circle' then { cx: parseFloat(node.attr('cx'), 10), cy: parseFloat(node.attr('cy'), 10), r: parseFloat(node.attr('r'), 10) } else { angle: @model.get('props').angle % 360, x: parseFloat(node.attr('x'), 10), y: parseFloat(node.attr('y'), 10), width: parseFloat(node.attr('width'), 10), height: parseFloat(node.attr('height'), 10) }
        window.App.trigger "element:resize", { el: @model.get('id'), props: props }


      @options.dots = @d3_el.selectAll('.dot').data([
        { x: x_center, y: dimensions.y, name: 'n' }
        { x: dimensions.x + dimensions.width, y: y_center, name: 'e' }
        { x: dimensions.x + dimensions.width, y: dimensions.y, name: 'ne' }
        { x: dimensions.x, y: dimensions.y, name: 'nw' }
      ], (d)->
        d.name
      ).enter().append('circle').classed('dot', true).attr('cx', (d)->
        d.x
      ).attr('cy', (d)->
        d.y
      ).attr('r', 3).attr('fill', @model.get('props').fill).call drag
        
    destroyResize: ->
      @d3_el.selectAll('.dot').remove()

  CanvasView = Marionette.CompositeView.extend
    childView: CanvasItem
    childViewContainer: "svg"
    modelEvents:
      'change:name': 'render'
    events:
      'click .bind-slide-select': 'onSlideEditClick'
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

