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
    
    switch key
      when 'x'
        @d3_el
          .selectAll 'tspan'
          .attr key, value + 10
        @d3_el 
          .selectAll 'text'
          .attr key, value
        node.attr key, value
      when 'y'
        @d3_el 
          .selectAll 'text'
          .attr key, value + 20
        node.attr key, value                 
      when 'text', 'texts'
        @d3_el.selectAll('text').remove()
        fsize  = props['font-size']

        text_node = @d3_el
          .append 'text'
          .attr 'x', props.x
          .attr 'y', props.y + 20
          .attr 'font-size', fsize
          .attr 'font-family', props['font-family']

        arr    = value.split '\n'
        for str, i in arr
          text_node
            .append 'tspan'
            .attr 'dy', if i is 0 then 0 else fsize
            .attr 'x', props.x + 10
            .text str

        node.attr 'width', text_node.node().getBBox().width + 20
        node.attr 'height', text_node.node().getBBox().height + 20
      when 'angle' 
        @setAngle value, center_x, center_y
      when 'font-size', 'font-family'
        @d3_el.selectAll('text').style key, value
      when 'fill'
        n = if @model.get('type') is 'text' then @d3_el.selectAll('text') else node
        n.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
      when 'background_fill'
        node.attr 'fill', if value.indexOf('#') is -1 then '#' + value else value
      when 'text_offset'
        # Это служебные поля, ничего делать не надо
        console.log 'junk'
      when 'fill-opacity'
        @d3_el.attr key, value
      else
        node.attr key, value
  setAngle: (angle, x_center, y_center)->
    @d3_el.attr 'transform', 'rotate(' + angle + ',' + x_center + ',' + y_center + ')'
  createTransition: (kf, next_kf, blockers)->
    =>
      hash_props = {  }

      for own key, value of next_kf.props
        old_value = kf.props[key]

        if blockers.indexOf(key) is -1
          if (key is 'fill') or (key is 'background_fill')
            value     = if value.indexOf('#') is -1 then '#' + value else value
            old_value = if old_value.indexOf('#') is -1 then '#' + old_value else old_value
          hash_props[key] = d3.interpolate(old_value, value) 
        else if (key is 'text') or (key is 'texts')
          @setNodeAttribute(@node, key, old_value)

      (t)=>
        for own key, value of hash_props
          if key isnt 'angle'
            @setNodeAttribute(@node, key, value(t)) 

        dimensions = @node.node().getBBox()
        @setAngle hash_props['angle'](t), hash_props['x'](t) * @options.scale.x + dimensions.width*0.5, hash_props['y'](t) * @options.scale.x + dimensions.height*0.5
  
  createEnterAnimation: (animation, start)->
    el = @d3_el

    $(el.node()).css 'opacity', 0

    duration = switch animation.type 
      when 'fadeIn' then animation.duration
      when 'sft', 'sfb', 'sfl', 'sfr' then animation.duration*0.8
      else
        0 

    setTimeout ->
      $(el.node()).animate { opacity: 1 }, duration
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

    external_delay = 0

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

        blockers = [ 'text', 'texts', 'fill-opacity' ]

        for animation in animations
          if (animation.keyframe is i) and (animation.type isnt 'none') and (animation.type isnt 'fadeIn') and (animation.type isnt 'fadeOut')
            start_kf = $.extend true, { }, kf 
            switch animation.type 
              when 'sft'
                start_kf.props.y = start_kf.props.y - 50 * @options.scale.x
              when 'sfb'
                start_kf.props.y = start_kf.props.y + 50 * @options.scale.x
              when 'lft'
                start_kf.props.y = - @d3_el.node().getBBox().height
              when 'lfb'
                start_kf.props.y = start_kf.props.y + $(@options.svg).height() / @options.scale.x
              when 'sfl'
                start_kf.props.x = start_kf.props.x - 50 * @options.scale.x
              when 'sfr'
                start_kf.props.x = start_kf.props.x + 50 * @options.scale.x
              when 'lfl'
                start_kf.props.x = - @d3_el.node().getBBox().width
              when 'lfr'
                start_kf.props.x = start_kf.props.x + $(@options.svg).width() / @options.scale.x

            transition
              .duration animation.duration
              .tween 'animation-'+i+'-before', @createTransition(start_kf, kf, blockers)
            transition = transition.transition()
            external_delay = animation.duration

        transition
          .duration next_kf.start - kf.start - external_delay
          .tween 'animation-'+i, @createTransition(kf, next_kf, blockers)

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
    .css 'background', '#ffffff'

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

  delay = 0
  current_slide = null

  getSlideDuration = (slide)->
    max_start = 0
    for element in slide.elements
      for k in element.keyframes
        max_start = k.start if k.start > max_start
    max_start

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
    delay = delay + getSlideDuration(slide) + 1000

  for slide in my_project.slides
    renderSlide slide