define "views/workspace/TimelineView", [ 
  "marionette"
  "templates/workspace/timeline"
  "templates/workspace/timeline_item"
  "behaviors/MCustomScrollbar"
  "jquery-ui"
], (Marionette, TimelineTemplate, TimelineItemTemplate)->
  TimelineItem = Marionette.ItemView.extend
    template: TimelineItemTemplate
    className: 'timeline_item custom.active'
    events:
      'click [data-animation]': 'playAnimation'
    initialize: ->
      @listenTo window.App, 'element:' + @model.get('id') + ':animation:change', @changeAnimation
    onRender: ->
      @el.setAttribute 'model-id', @model.get 'id'
    playAnimation: (e)->
      window.App.trigger 'element:' + @model.get('id') + ':animation:play', JSON.parse(e.target.getAttribute('data-animation'))
    changeAnimation: (data)->
      @model.set 'animations', data.animations
      @render()
  Marionette.CompositeView.extend
    template: TimelineTemplate
    childView: TimelineItem
    # behaviors:
    #   MCustomScrollbar: { mouseWheel: { invert: true } }
    className: 'timeline'
    childViewContainer: ".bind-timeline-items"
    events:
      'sortstop .bind-timeline-items': 'reOrderElements'
    onRender: ->
      setTimeout =>
        @$el.find('.bind-timeline-items').sortable
          placeholder: "ui-state-highlight"
        @$el.disableSelection()
      , 0
    initialize: (options)->
      maxTime    = { minutes: 0, seconds: 0, milliseconds: 0 }

      for element in options.elements.toJSON()
        for animation in element.animations
          animationTime        = { minutes: 0, seconds: 0, milliseconds: 0 }
          durationSeconds      = Math.floor (animation.duration + animation.start) / 1000
          durationMilliSeconds = animation.duration + animation.start

          animationTime.minutes  = Math.floor durationSeconds / 60
          animationTime.seconds  = durationSeconds % 60
          animationTime.milliseconds = durationMilliSeconds % 1000

          maxTime = animationTime if (maxTime.minutes < animationTime.minutes) or ((maxTime.minutes is animationTime.minutes) and (maxTime.seconds < animationTime.seconds)) or ((maxTime.seconds is animationTime.seconds) and (maxTime.milliseconds < animationTime.milliseconds))

      timesegments = [  ]
      if maxTime.minutes isnt 0
        for i in [0..maxTime.minutes-1]
          for j in [0..59]
            for k in [0..2]
              timesegments.push { minutes: i, seconds: j, milliseconds: k*50 }

      for j in [0..maxTime.seconds-1]
        for k in [0..1]
          timesegments.push { minutes: maxTime.minutes, seconds: j, milliseconds: k*50 }

      for k in [0..Math.floor(maxTime.milliseconds / 500)]
        timesegments.push { minutes: maxTime.minutes, seconds: maxTime.seconds, milliseconds: k*50 }

      @model = new Backbone.Model { timesegments: timesegments }

      @collection = options.elements

    reOrderElements: ->
      @$el.find('.timeline_item').each (index, element)=>
        model_id = element.getAttribute 'model-id'
        model    = @collection.get model_id

        if model.get('order') isnt index
          model.set 'order', index
          window.App.trigger "element:reorder", { el: model.get('id'), order: index }
