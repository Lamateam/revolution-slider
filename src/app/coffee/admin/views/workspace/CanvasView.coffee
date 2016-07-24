define "views/workspace/CanvasView", [ 
  "marionette"
  "libs/helpers"
  "views/workspace/TimelineView"
  "templates/workspace/canvas"
  "d3"
], (Marionette, Helpers, TimelineView, CanvasTemplate)->
  html = d3.select 'html'

  pageX = 0
  pageY = 0
  $(window).on 'mousemove', (e)->
    pageX = e.pageX
    pageY = e.pageY

  CanvasItem = Marionette.ItemView.extend
    tagName: "g"
    canResize: true
    canMove: true
    canRotate: true
    id: ->
      "element_" + @model.get "id"
    _createElement: (tagName)->
      @d3_el.remove() if @d3_el isnt undefined
      svg        = d3.select(@options.svg)
      @d3_el     = svg.append(tagName)

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

      @initDots @options.node
    setInactive: ->
      @d3_el.attr "stroke", "transparent"
      @destroyDots()
    attachElContent: ->
      @setD3Attributes @model.get('type'), @model.get('keyframes')[@current_keyframe].props
    setD3Attributes: (type, props)->
      @options.node = @d3_el.append type if @options.node is undefined
      @setNodeAttribute(@options.node, key, value) for own key, value of props

      @canResize = false if type is 'text'
      @canRotate = false if type is 'text'
      
      @setActive() if @getOption("stateModel").get("isElementSelected") is @model.get("id")

      @initEvents @options.node
    initialize: ->
      @transitions      = [  ]
      @current_keyframe = 0

      @listenTo @getOption("stateModel"), "change:isElementSelected", @onSomeElementSelected
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:create', @createKeyframe
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:select', @selectKeyframe
      @listenTo window.App, 'element:' + @model.get('id') + ':change', @onElementChange
    initEvents: (n)->
      id = @model.get 'id'
      n.on "click", ->
        return if d3.event.defaultPrevented
        window.App.trigger "element:click", { id: id }
      # @listenTo window.App, 'element:' + @model.get('id') + ':animation:play', @playAnimation
      @listenTo window.App, 'element:' + @model.get('id') + ':animations:play', @playAnimations
    onSomeElementSelected: ->
      if @getOption("stateModel").get("isElementSelected") is @model.get("id") then @setActive() else @setInactive()
    setNodeAttribute: (node, key, value)->
      props    = @model.get('keyframes')[@current_keyframe].props
      center_x = if @model.get('type') is 'circle' then props.cx else props.x + props.width*0.5
      center_y = if @model.get('type') is 'circle' then props.cy else props.y + props.height*0.5
      switch 
        when key is 'x', key is 'y'
          node.selectAll('tspan').attr 'x', props.x
          @d3_el.data [ { x: props.x, y: props.y } ]
          node.attr key, value
        when key is 'text', key is 'texts'
          node.selectAll('tspan').remove()
          arr   = value.split '\n'
          fsize = props['font-size']
          for str, i in arr
            node.append('tspan').attr('dy', if i is 0 then 0 else fsize).attr('x', props.x).text(str)
        when key is 'angle' 
          @setAngle value, center_x, center_y
        when true then node.attr key, value
    setAngle: (angle, x_center, y_center)->
      @d3_el.attr 'transform', 'rotate(' + angle + ',' + x_center + ',' + y_center + ')'
    moveDots: ->
      dimensions = @options.node.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5

      data       = []
      if @canResize
        data.push { x: x_center, y: dimensions.y, name: 'n' }
        data.push { x: dimensions.x + dimensions.width, y: y_center, name: 'e' }
        data.push { x: dimensions.x, y: y_center, name: 'w' }
        data.push { x: x_center, y: dimensions.y + dimensions.height, name: 's' }
      if @canRotate
        data.push { x: dimensions.x + dimensions.width, y: dimensions.y, name: 'ne' }
        data.push { x: dimensions.x, y: dimensions.y, name: 'nw' }
        data.push { x: dimensions.x + dimensions.width, y: dimensions.y + dimensions.height, name: 'se' }
        data.push { x: dimensions.x, y: dimensions.y + dimensions.height, name: 'sw' }
      if @canMove
        data.push { x: x_center, y: y_center, name: 'c' }

      @options.dots.data(data, (d)->
        d.name
      ).attr('cx', (d)->
        d.x
      ).attr('cy', (d)->
        d.y
      )
    initDots: (n)->
      @destroyDots()

      dimensions = n.node().getBBox()
      x_center   = dimensions.x + dimensions.width*0.5
      y_center   = dimensions.y + dimensions.height*0.5
      type       = @model.get 'type'
      props      = @model.get('keyframes')[@current_keyframe].props
      node       = @options.node

      drag = d3.behavior.drag()
      drag.on 'drag', (d)=>
        offset     = $('svg').offset()
        move_x     = pageX - offset.left
        move_y     = pageY - offset.top
        x          = d3.event.x
        y          = d3.event.y
        dimensions = n.node().getBBox()
        x_center   = dimensions.x + dimensions.width*0.5
        y_center   = dimensions.y + dimensions.height*0.5

        new_d = Math.sqrt Math.pow( y - y_center, 2 ) + Math.pow( x - x_center, 2 )
        switch d.name
          when 'n', 's'
            dh = new_d - dimensions.height*0.5

            props.height = dimensions.height + dh
            props.y      = dimensions.y - dh if d.name is 'n'

            @setNodeAttribute n, 'height', props.height
            @setNodeAttribute n, 'y', props.y
            @setNodeAttribute(n, 'angle', props.angle) if @canRotate
          when 'w', 'e'
            dw = new_d - dimensions.width*0.5

            props.width = dimensions.width + dw
            props.x     = dimensions.x - dw if d.name is 'w'

            @setNodeAttribute n, 'width', props.width
            @setNodeAttribute n, 'x', props.x
            @setNodeAttribute(n, 'angle', props.angle) if @canRotate            
          when 'ne', 'nw', 'se', 'sw'
            if (x isnt x_center) or (y isnt y_center)
              props.angle = props.angle + (180 / Math.PI) * Math.atan2(y - y_center, x - x_center)
              dalpha      = (180 / Math.PI) * Math.atan(dimensions.width / dimensions.height)
              props.angle = props.angle + 90 - dalpha if d.name is 'ne'
              props.angle = props.angle + 90 + dalpha if d.name is 'nw'
              props.angle = props.angle + 270 + dalpha if d.name is 'se'
              props.angle = props.angle + 270 - dalpha if d.name is 'sw'
              props.angle = props.angle % 360
              @setNodeAttribute n, 'angle', props.angle
          when 'c'
            props.x = move_x - props.width*0.5
            props.y = move_y - props.height*0.5
            # props.x = props.x + d3.event.dx
            # props.y = props.y + d3.event.dy
            # @setNodeAttribute(n, 'angle', props.angle) if @canRotate
            @setNodeAttribute n, 'x', props.x
            @setNodeAttribute n, 'y', props.y

            @setAngle props.angle, move_x, move_y
        
        @moveDots()

      drag.on 'dragend', =>
        window.App.trigger "element:resize", { el: @model.get('id'), keyframe: @current_keyframe, props: props }

      data = []
      if @canResize
        data.push { x: x_center, y: dimensions.y, name: 'n' }
        data.push { x: dimensions.x + dimensions.width, y: y_center, name: 'e' }
        data.push { x: dimensions.x, y: y_center, name: 'w' }
        data.push { x: x_center, y: dimensions.y + dimensions.height, name: 's' }
      if @canRotate
        data.push { x: dimensions.x + dimensions.width, y: dimensions.y, name: 'ne' }
        data.push { x: dimensions.x, y: dimensions.y, name: 'nw' }
        data.push { x: dimensions.x + dimensions.width, y: dimensions.y + dimensions.height, name: 'se' }
        data.push { x: dimensions.x, y: dimensions.y + dimensions.height, name: 'sw' }
      if @canMove
        data.push { x: x_center, y: y_center, name: 'c' }

      @options.dots = @d3_el.selectAll('.dot')
        .data data, (d)->
          d.name
        .enter().append('circle').classed('dot', true)
        .attr 'cx', (d)->
          d.x
        .attr 'cy', (d)->
          d.y
        .attr 'r', 3
        .attr 'stroke', 'black'
        .attr 'fill', @model.get('keyframes')[@current_keyframe].props.fill
        .call drag
    destroyDots: ->
      @d3_el.selectAll('.dot').remove()
    createKeyframe: (data)->
      props = _.clone @model.get('keyframes')[@current_keyframe].props
      window.App.trigger "element:create_keyframe", { el: @model.get('id'), props: props, start: data.start }
      @current_keyframe = @model.get('keyframes').length - 1
    selectKeyframe: (data)->
      @current_keyframe = data.id 
      @render()
    createTransition: (kf, next_kf)->
      =>
        hash_props = {  }

        hash_props[key] = d3.interpolate(kf.props[key], value) for own key, value of next_kf.props
        
        (t)=>
          for own key, value of hash_props
            if key isnt 'angle'
              @setNodeAttribute(@options.node, key, value(t)) 

          dimensions = @options.node.node().getBBox()
          @setAngle hash_props['angle'](t), hash_props['x'](t) + dimensions.width*0.5, hash_props['y'](t) + dimensions.height*0.5

          @moveDots() if @getOption("stateModel").get("isElementSelected") is @model.get("id")
    playAnimations: (data)->
      el = @d3_el
      transition = el

      @selectKeyframe { id: 0 }

      for kf, i in data.keyframes
        console.log 'animation: ', i
        next_kf = data.keyframes[i+1]
        if next_kf isnt undefined
          transition = transition.transition()
            .duration next_kf.start-kf.start
            .tween 'animation-'+i, @createTransition(kf, next_kf)
    onElementChange: (data)->
      props = @model.get('keyframes')[@current_keyframe].props
      props[key] = value for own key, value of data.props
      window.App.trigger "element:resize", { el: @model.get('id'), keyframe: @current_keyframe, props: props }

  CanvasWidget = CanvasItem.extend
    canResize: false
    canRotate: false
    attachElContent: ->
      visualize = @model.get 'visualize'
      @setD3Attributes visualize.type, visualize.props

  CanvasView = Marionette.CompositeView.extend
    childView: CanvasItem
    childViewContainer: "svg"
    modelEvents:
      'change:name': 'render'
      'change:background': 'render'
    events:
      'click .bind-slide-select': 'onSlideEditClick'
    buildChildView: (item, ItemViewType, itemViewOptions)->
      options = _.extend { model: item }, itemViewOptions
      View = switch
        when item.get('type') is 'widget' then CanvasWidget
        when true then CanvasItem
      new View options
    childViewOptions: ->
      res = 
        stateModel: @options.stateModel
        svg: @el.getElementsByTagName("svg")[0]
    attachHtml: (collectionView, childView, index)->
    templateHelpers: ->
      res = 
        width: @options.width
        height: @options.height
    template: CanvasTemplate
    onRender: ->
      setTimeout =>
        manager = new Marionette.RegionManager
          regions:
            timelineRegion: '#timeline'

        manager.get('timelineRegion').show new TimelineView
          elements: @collection
      , 0
    onSlideEditClick: ->
      window.App.trigger "slide:select", { id: @model.get 'id' }

