define "views/workspace/TimelineView", [ 
  "marionette"
  "templates/workspace/timeline"
  "templates/workspace/timeline_item"
  "behaviors/MCustomScrollbar"
], (Marionette, TimelineTemplate, TimelineItemTemplate)->
  TimelineItem = Marionette.ItemView.extend
    template: TimelineItemTemplate

  Marionette.CompositeView.extend
    template: TimelineTemplate
    childView: TimelineItem
    behaviors:
      MCustomScrollbar: { mouseWheel: { invert: true } }
    className: 'timeline'
    childViewContainer: ".bind-timeline-items"
    initialize: (options)->
      maxTime = { minutes: 0, seconds: 0 }
      console.log options
      for element in options.elements.toJSON()
        for animation in element.animations
          animationTime   = { minutes: 0, seconds: 0 }
          durationSeconds = Math.round (animation.duration + animation.start) / 10

          animationTime.minutes = Math.floor durationSeconds / 60
          animationTime.seconds = durationSeconds % 60

          maxTime = animationTime if (maxTime.minutes < animationTime.minutes) or ((maxTime.minutes is animationTime.minutes) and (maxTime.seconds < animationTime.seconds))

      console.log maxTime

      timesegments = [  ]
      if maxTime.minutes isnt 0
        for i in [0..maxTime.minutes-1]
          for j in [0..5]
            timesegments.push { minutes: i, seconds: j*10 }

      for j in [0..Math.floor(maxTime.seconds / 10)]
        timesegments.push { minutes: maxTime.minutes, seconds: j*10 }

      console.log timesegments

      @model = new Backbone.Model { timesegments: timesegments }