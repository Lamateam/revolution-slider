define "views/workspace/TimelineView", [ 
  "marionette"
  "templates/workspace/timeline"
  "templates/workspace/timeline_item"
  "behaviors/MCustomScrollbar"
  "jquery-ui"
], (Marionette, TimelineTemplate, TimelineItemTemplate)->
  TimelineItem = Marionette.ItemView.extend
    template: TimelineItemTemplate
    className: 'timeline_item custom active'
    ui:
      runner: '.timeline_time'
      keyframes: '.timeline_item-keyframe'
    events:
      'click [data-animation]': 'playAnimation'
      'click .timeline_item-keyframe': 'selectKeyframe'
    modelEvents:
      'sync': 'render'
    initialize: ->
      @active_animations = [  ]
      @active_keyframe   = 0
      @listenTo window.App, 'element:' + @model.get('id') + ':animation:change', @changeAnimation
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:create', @onKeyframeCreate
    onRender: ->
      @el.setAttribute 'model-id', @model.get 'id'
      @ui.runner.hide()
      @_selectKeyframe(@active_keyframe)
    runAll: ->
      for animation in @model.get 'animations'
        @runAnimation animation, animation.start
    runAnimation: (data, start=0)->
      r    = @ui.runner
      left = data.start*0.12
      arr  = @active_animations

      arr.push setTimeout ->
        r.css { left: left + 'px' }
        r.show()
        handler = (now)->
          ->
            r.css { left: (left+now*0.12) + 'px' }

        for i in [0..data.duration]
          setTimeout handler(i), i

        setTimeout ->
          arr.pop()
          r.hide() if arr.length is 0
        , data.duration
      , start 
    playAnimation: (e)->
      data = JSON.parse(e.target.getAttribute('data-animation'))
      window.App.trigger 'element:' + @model.get('id') + ':animation:play', data
      @runAnimation data
    changeAnimation: (data)->
      @model.set 'animations', data.animations
      @render()
    _selectKeyframe: (id)->
      @active_keyframe = id
      el = @$el.find '[keyframe-id=' + id + ']'
      @ui.keyframes.removeClass 'active'
      el.addClass 'active'      
    selectKeyframe: (e)->
      id = e.target.getAttribute 'keyframe-id'

      @_selectKeyframe id

      window.App.trigger 'element:' + @model.get('id') + ':keyframe:select', { id: id }
    onKeyframeCreate: ->
      console.log @model.get('keyframes').length
      @active_keyframe = @model.get('keyframes').length - 1
  Marionette.CompositeView.extend
    template: TimelineTemplate
    childView: TimelineItem
    behaviors:
      MCustomScrollbar: { mouseWheel: { invert: true } }
    className: 'timeline'
    childViewContainer: ".bind-timeline-items"
    events:
      'sortstop .bind-timeline-items': 'reOrderElements'
      'dblclick .bind-timeline-items': 'createKeyframe'
    onRender: ->
      setTimeout =>
        @$el.find('.bind-timeline-items').sortable
          placeholder: "ui-state-highlight"
        @$el.disableSelection()
      , 0
    playAnimations: ->
      @collection.each (model)->
        window.App.trigger 'element:' + model.get('id') + ':animations:play', { animations: model.get('animations'), keyframes: model.get('keyframes') }
      # @children.each (view)->
      #   view.runAll()
    initialize: (options)->
      # maxTime    = { minutes: 0, seconds: 0, milliseconds: 0 }

      # for element in options.elements.toJSON()
      #   for animation in element.animations
      #     animationTime        = { minutes: 0, seconds: 0, milliseconds: 0 }
      #     durationSeconds      = Math.floor (animation.duration + animation.start) / 1000
      #     durationMilliSeconds = animation.duration + animation.start

      #     animationTime.minutes  = Math.floor durationSeconds / 60
      #     animationTime.seconds  = durationSeconds % 60
      #     animationTime.milliseconds = durationMilliSeconds % 1000

      #     maxTime = animationTime if (maxTime.minutes < animationTime.minutes) or ((maxTime.minutes is animationTime.minutes) and (maxTime.seconds < animationTime.seconds)) or ((maxTime.seconds is animationTime.seconds) and (maxTime.milliseconds < animationTime.milliseconds))

      # timesegments = [  ]
      # if maxTime.minutes isnt 0
      #   for i in [0..maxTime.minutes-1]
      #     for j in [0..59]
      #       for k in [0..2]
      #         timesegments.push { minutes: i, seconds: j, milliseconds: k*50 }

      # for j in [0..maxTime.seconds-1]
      #   for k in [0..1]
      #     timesegments.push { minutes: maxTime.minutes, seconds: j, milliseconds: k*50 }

      # for k in [0..Math.floor(maxTime.milliseconds / 500)]
      #   timesegments.push { minutes: maxTime.minutes, seconds: maxTime.seconds, milliseconds: k*50 }
      timesegments = [  ]

      for i in [0..5]
        for j in [0..60]
          for k in [0..1]
            timesegments.push { minutes: i, seconds: j, milliseconds: k*50 }

      @model = new Backbone.Model { timesegments: timesegments }

      @collection = options.elements

      @listenTo window.App, 'animations:play', @playAnimations
    reOrderElements: ->
      @$el.find('.timeline_item').each (index, element)=>
        model_id = element.getAttribute 'model-id'
        model    = @collection.get model_id

        if model.get('order') isnt index
          model.set 'order', index
          window.App.trigger "element:reorder", { el: model.get('id'), order: index }
    createKeyframe: (e)->
      offset   = $(e.target).offset()
      model_id = e.target.getAttribute 'model-id'

      x = e.pageX - offset.left - 53
      
      start = Math.floor x * 8.333333333333334
      
      window.App.trigger 'element:' + model_id + ':keyframe:create', { start: start } 