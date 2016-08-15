class Element 
  constructor: (@svg, @model, @options)->
  setNodeAttribute: (node, key, value)->
    props    = @model.keyframes[0].props
    dims     = node.node().getBBox()

    center_x = (if @model.type is 'circle' then props.cx else props.x + (if props.width is undefined then dims.width else props.width)*0.5) * @options.scale.x
    center_y = (if @model.type is 'circle' then props.cy else props.y + (if props.height is undefined then dims.height else props.height)*0.5)  * @options.scale.x
    
    # переводим параметры в актуальный размер
    value = value * @options.scale.x if (key is 'x') or (key is 'width') or (key is 'y') or (key is 'height')
    # value = value * @options.scale.y if (key is 'y') or (key is 'height')
    
    switch 
      when key is 'x'
        # двигаем текст
        @d3_el
          .selectAll 'tspan'
          .attr key, value + 10 * @options.scale.x
        @d3_el 
          .selectAll 'text'
          .attr key, value
        node.attr key, value
      when key is 'y'
        @d3_el 
          .selectAll 'text'
          .attr key, value + 20 * @options.scale.x
        node.attr key, value                 
      when key is 'text', key is 'texts'
        @d3_el.selectAll('text').remove()

        text_node = @d3_el
          .append 'text'
          .attr 'x', props.x * @options.scale.x
          .attr 'y', (props.y + 20) * @options.scale.x

        arr    = value.split '\n'
        fsize  = props['font-size']
        for str, i in arr
          text_node
            .append 'tspan'
            .attr 'dy', if i is 0 then 0 else fsize
            .attr 'x', (props.x + 10) * @options.scale.x
            .text str

        node.attr 'width', text_node.node().getBBox().width + 20 * @options.scale.x
        node.attr 'height', text_node.node().getBBox().height + 20 * @options.scale.x
      when key is 'angle' 
        @setAngle value, center_x, center_y
      when key is 'font-size'
        @d3_el.selectAll('text').style key, value
      when key is 'fill'
        n = if @model.type is 'text' then @d3_el.selectAll('text') else node
        n.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
      when key is 'background_fill'
        node.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
      when key is 'text_offset'
        # Это служебные поля, ничего делать не надо
        console.log 'junk'
      when key is 'fill-opacity'
        node.attr key, value
      when true then node.attr key, value
  setAngle: (angle, x_center, y_center)->
    @d3_el.attr 'transform', 'rotate(' + angle + ',' + x_center + ',' + y_center + ')'
  createTransition: (kf, next_kf)->
    =>
      hash_props = {  }

      for own key, value of next_kf.props
        if (key isnt 'text') and (key isnt 'texts') and (key isnt 'fill-opacity')
          old_value = kf.props[key]

          if (key is 'fill') or (key is 'background_fill')
            value     = if value.indexOf('#') is -1 then '#' + value else value
            old_value = if old_value.indexOf('#') is -1 then '#' + old_value else old_value
          hash_props[key] = d3.interpolate(old_value, value) 

      (t)=>
        for own key, value of hash_props
          if key isnt 'angle'
            @setNodeAttribute(@node, key, value(t)) 

        dimensions = @node.node().getBBox()
        @setAngle hash_props['angle'](t), hash_props['x'](t) * @options.scale.x + dimensions.width*0.5, hash_props['y'](t) * @options.scale.x + dimensions.height*0.5
  
  createEnterAnimation: (animation, start)->
    el = @d3_el
    switch animation.type 
      when 'fadeIn'
        el.style 'opacity', 0

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

  playAnimations: (keyframes=@model.keyframes)->
    el = @d3_el

    transition = el

    animations = @model.animations

    for animation, i in animations
      if animation.link is 'enter'
        @createEnterAnimation animation, keyframes[animation.keyframe].start
      else if animation.link is 'leave'
        @createLeaveAnimation animation, keyframes[animation.keyframe].start, i is animations.length-1


    for kf, i in keyframes
      next_kf = keyframes[i+1]
      if next_kf isnt undefined
        transition = transition.transition()

        if i is 0 and kf.start isnt 0
          transition.delay kf.start

        transition
          .duration next_kf.start - kf.start
          .tween 'animation-'+i, @createTransition(kf, next_kf)

  render: ->
    # рисуем лейаут
    @d3_el = @svg.append 'g'

    # рисуем элемент
    @node  = @d3_el.append if @model.type isnt 'text' then @model.type else 'rect'

    if @model.keyframes.length < 2
      setTimeout =>
        props = @model.keyframes[0].props
        @setNodeAttribute(@node, key, value) for own key, value of props
      , @model.keyframes[0].start

    @
  fadeOut: (duration)->
    el = @d3_el

    if el.style('opacity') isnt 0
      step = 1 / duration

      handler = (i)->
        ->
          el.style 'opacity', (duration - i)*step

      for i in [0..duration]
        setTimeout handler(i), i

class Slide 
  createTransition: (old_value, value, key)->
    =>
      i = d3.interpolate(old_value, value)

      (t)=>
        @svg.style key, i(t)
  constructor: (@svg, @slide)->
    @els = [  ]

    @slide.elements = @slide.elements.sort (a, b)->
      if a.order < b.order then -1 else 1

    for element in @slide.elements
      el = new Element(@svg, element, { scale: scale })
      @els.push el

  enter: ->
    old_color = @svg.style 'background-color'
    old_color = '#ffffff' if old_color is undefined
    old_color = '#' + old_color if old_color.indexOf('#') is -1

    color     = @slide.background
    color     = '#' + color if color.indexOf('#') is -1

    console.log old_color, color

    @svg.transition()
      .duration 800
      .tween 'animation-slide-background', @createTransition(old_color, color, 'background-color')
    
    @
  render: ->
    for el in @els
      el.render().playAnimations()
    @
  fadeOut: ->
    for element in @els
      element.fadeOut 200

$(document).ready ->
  winWidth  = $(window).width()
  winHeight = $(window).height()

  $('svg')
    .width winWidth
    .height winHeight

  switch my_project.dim 
    when '4x3'
      oWidth = 640
      oHeight = 480
    when '3x4'
      oWidth = 480
      oHeight = 640
    when '16x9'
      oWidth = 640
      oHeight = 360
    when '9x16'
      oWidth = 360
      oHeight = 640

  window.scale = 
    x: winWidth / oWidth
    y: winHeight / oHeight

  svg = d3.select('svg')
  svg.style 'background', '#ffffff'

  delay = 0
  current_slide = null

  renderSlide = (slide)->
    setTimeout ->
      current_slide.fadeOut() if current_slide isnt null
      _delay = if slide isnt null then 200 else 0
      setTimeout ->
        current_slide = new Slide svg, slide
        setTimeout -> 
          current_slide.enter().render() 
        , 200
      , _delay
    , delay     
    delay = delay + slide.duration*1000 + 1000

  for slide in my_project.slides
    renderSlide slide