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

      svg        = d3.select @options.svg
      @d3_el     = svg.append tagName

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
      @d3_el.attr "stroke", '#000000'
      @initDots @options.node
    setInactive: ->
      @d3_el.attr "stroke", "transparent"
      @destroyDots()
    attachElContent: ->
      @setD3Attributes @model.get('type'), @model.get('keyframes')[@current_keyframe].props
    setD3Attributes: (type, props)->
      if @options.node is undefined
        @options.node = @d3_el.append if type isnt 'text' then type else 'rect'

      # @setNodeAttribute(@options.node, key, value) for own key, value of props

      @canResize = false if type is 'text'
      # @canRotate = false if type is 'text'
      
      # @setActive() if @getOption("stateModel").get("isElementSelected") is @model.get("id")

      # @initEvents @options.node
    initialize: ->
      @transitions      = [  ]
      @current_keyframe = 0

      @listenTo @getOption("stateModel"), "change:isElementSelected", @onSomeElementSelected
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:create', @createKeyframe
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:select', @selectKeyframe
      @listenTo window.App, 'element:' + @model.get('id') + ':animation:select', @selectAnimation
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:change', @changeKeyframe
      @listenTo window.App, 'element:' + @model.get('id') + ':change', @onElementChange
      @listenTo window.App, 'element:' + @model.get('id') + ':animations:play', @playAnimations
    
      @is_play = false
    onRender: ->
      setTimeout =>

        props = @model.get('keyframes')[@current_keyframe].props

        @setNodeAttribute(@options.node, key, value) for own key, value of props
        
        @setActive() if @getOption("stateModel").get("isElementSelected") is @model.get("id")

        @initEvents @options.node

        # if @model.get('type') is 'text'

        #   @d3_el.selectAll('.background_rect').remove()

        #   dimensions = @d3_el.node().getBBox()
        #   offset     = props.text_offset
        #   fill       = props.background_fill

        #   @d3_el
        #     .insert 'rect', ':first-child'
        #     .classed 'background_rect', true
        #     .attr 'x', dimensions.x - offset
        #     .attr 'y', dimensions.y - offset
        #     .attr 'width', dimensions.width + offset*2
        #     .attr 'height', dimensions.height + offset*2
        #     .attr 'fill', if fill.indexOf('#') is -1 then '#' + fill else fill

      , 0

    initEvents: (n)->
      n.on "click", @onNodeClick.bind @
      @d3_el.selectAll('text').on 'click', @onNodeClick.bind @
    onNodeClick: ->
      return if d3.event && d3.event.defaultPrevented
      id = @model.get 'id'
      window.App.trigger "element:click", { id: id }      
    onSomeElementSelected: ->
      if @getOption("stateModel").get("isElementSelected") is @model.get("id") then @setActive() else @setInactive()
    setNodeAttribute: (node, key, value)->
      props    = @model.get('keyframes')[@current_keyframe].props
      dims     = node.node().getBBox()
      center_x = if @model.get('type') is 'circle' then props.cx else props.x + (if props.width is undefined then dims.width else props.width)*0.5
      center_y = if @model.get('type') is 'circle' then props.cy else props.y + (if props.height is undefined then dims.height else props.height)*0.5
      switch 
        when key is 'x'
          @d3_el
            .selectAll 'tspan'
            .attr key, value + 10
          @d3_el 
            .selectAll 'text'
            .attr key, value
          node.attr key, value
        when key is 'y'
          @d3_el 
            .selectAll 'text'
            .attr key, value + 20
          node.attr key, value                 
        when key is 'text', key is 'texts'
          @d3_el.selectAll('text').remove()

          text_node = @d3_el
            .append 'text'
            .attr 'x', props.x
            .attr 'y', props.y + 20

          arr    = value.split '\n'
          fsize  = props['font-size']
          for str, i in arr
            text_node
              .append 'tspan'
              .attr 'dy', if i is 0 then 0 else fsize
              .attr 'x', props.x + 10
              .text str

          node.attr 'width', text_node.node().getBBox().width + 20
          node.attr 'height', text_node.node().getBBox().height + 20
        when key is 'angle' 
          @setAngle value, center_x, center_y
        when key is 'font-size'
          @d3_el.selectAll('text').style key, value
        when key is 'fill'
          n = if @model.get('type') is 'text' then @d3_el.selectAll('text') else node
          n.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
        when key is 'background_fill'
          node.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
        when key is 'text_offset'
          # Это служебные поля, ничего делать не надо
          console.log 'junk'
        when true then node.attr key, value
    setAngle: (angle, x_center, y_center)->
      if @canRotate
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

        new_d = Math.sqrt Math.pow( move_y - y_center, 2 ) + Math.pow( move_x - x_center, 2 )
        switch d.name
          when 'n', 's'
            dh = new_d - dimensions.height*0.5

            props.height = dimensions.height + dh
            props.y      = dimensions.y - dh if d.name is 'n'

            @setNodeAttribute n, 'height', props.height
            @setNodeAttribute n, 'y', props.y

            _dimensions = n.node().getBBox()
            @setAngle props.angle, _dimensions.x + _dimensions.width*0.5, _dimensions.y + _dimensions.height*0.5 if @canRotate
          when 'w', 'e'
            dw = new_d - dimensions.width*0.5

            props.width = dimensions.width + dw
            props.x     = dimensions.x - dw if d.name is 'w'

            @setNodeAttribute n, 'width', props.width
            @setNodeAttribute n, 'x', props.x

            # @setAngle props.angle, props.x + dimensions.width*0.5, props.y + dimensions.height*0.5 if @canRotate
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
            dy = if props['font-size'] is undefined then 0 else parseInt(props['font-size'], 10)
            
            props.x = move_x - dimensions.width*0.5
            props.y = move_y - dimensions.height*0.5 

            @setNodeAttribute n, 'x', props.x
            @setNodeAttribute n, 'y', props.y

            @setAngle props.angle, move_x, move_y

            # @d3_el
            #   .selectAll '.background_rect'
            #   .attr 'y', move_y - dimensions.height*0.5 - props.text_offset
        
        @moveDots()

      drag.on 'dragend', =>
        window.App.trigger "element:resize", { el: @model.get('id'), keyframe: @current_keyframe, props: { props: props } }

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
        .attr 'fill', '#' + @model.get('keyframes')[@current_keyframe].props.fill
        .call drag
    destroyDots: ->
      @d3_el.selectAll('.dot').remove()
    createKeyframe: (data)->
      keyframes = @model.get('keyframes')
      props = _.clone keyframes[keyframes.length-1].props
      window.App.trigger "element:create_keyframe", { el: @model.get('id'), props: props, start: data.start }
      @current_keyframe = @model.get('keyframes').length - 1
      @onNodeClick()
    selectKeyframe: (data)->
      @current_keyframe = data.id 
      @render()
    selectAnimation: (data)->
      window.App.trigger "element:select_animation", { el: @model.get('id'), data: data }
    createTransition: (kf, next_kf)->
      =>
        hash_props = {  }

        for own key, value of next_kf.props
          if (key isnt 'text') and (key isnt 'texts')
            old_value = kf.props[key]

            if key is 'fill'
              value     = '#' + value 
              old_value = '#' + old_value

            hash_props[key] = d3.interpolate(old_value, value) 

        (t)=>
          for own key, value of hash_props
            if key isnt 'angle'
              @setNodeAttribute(@options.node, key, value(t)) 

          dimensions = @options.node.node().getBBox()
          @setAngle hash_props['angle'](t), hash_props['x'](t) + dimensions.width*0.5, hash_props['y'](t) + dimensions.height*0.5 if @canRotate

          @moveDots() if @getOption("stateModel").get("isElementSelected") is @model.get("id")
    
    createEnterAnimation: (animation, start)->
      el = @d3_el
      switch animation.type 
        when 'fadeIn'
          step = 1 / animation.duration

          handler = (i)->
            ->
              el.style 'opacity', i*step
          setTimeout ->
            for i in [0..animation.duration]
              setTimeout handler(i), i
          , start

    createLeaveAnimation: (animation, end, isLast)->
      el = @d3_el

      switch animation.type 
        when 'fadeOut'
          step = 1 / animation.duration

          handler = (i)->
            ->
              el.style 'opacity', (end - i)*step

          for i in [end - animation.duration..end]
            setTimeout handler(i), i  

          # if isLast
          #   setTimeout ->
          #     el.style 'opacity', 1
          #   , end

    playAnimations: (data)->
      el = @d3_el

      transition = el

      @selectKeyframe { id: 0 }

      for kf, i in data.keyframes
        next_kf = data.keyframes[i+1]
        if next_kf isnt undefined
          transition = transition.transition()

          if i is 0 and kf.start isnt 0
            transition.delay kf.start

          transition
            .duration next_kf.start - kf.start
            .tween 'animation-'+i, @createTransition(kf, next_kf)

      animations = @model.get 'animations'

      for animation, i in animations
        if animation.link is 'enter'
          @createEnterAnimation animation, data.keyframes[animation.keyframe].start
        else if animation.link is 'leave'
          @createLeaveAnimation animation, data.keyframes[animation.keyframe].start, i is animations.length-1


    onElementChange: (data)->
      props = @model.get('keyframes')[@current_keyframe].props
      props[key] = value for own key, value of data.props
      window.App.trigger "element:resize", { el: @model.get('id'), keyframe: @current_keyframe, props: { props: props } }

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

