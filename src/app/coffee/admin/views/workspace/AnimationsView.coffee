define "views/workspace/AnimationsView", [ 
  "marionette"
  "collections/AnimationsCollection"
  "templates/workspace/animations"
  "templates/workspace/animations_item"
], (Marionette, AnimationsCollection, AnimationsTemplate, AnimationsItemTemplate)->
  AnimationItem = Marionette.ItemView.extend
    template: AnimationsItemTemplate
    events: 
      'blur .bind-duration': 'changeDuration'
      'change .bind-effect': 'changeEffect'
      'change .bind-type': 'changeType'
    changeDuration: (e)->
      duration = parseInt e.target.value, 10
      @model.collection.changeAnimation @model.get('id'), { duration: duration }
    changeEffect: (e)->
      effect = $(e.target).val()
      @model.collection.changeAnimation @model.get('id'), { effect: effect }
    changeType: (e)->
      type = $(e.target).val()
      @model.collection.changeAnimation @model.get('id'), { type: type }
    onRender: ->
      @$el.hide() if !@model.get('visible')
  Marionette.CompositeView.extend
    template: AnimationsTemplate
    childView: AnimationItem
    childViewContainer: ".bind-animations"
    events:
      'click .bind-add-animation': 'addAnimation'
    templateHelpers: ->
      res = 
        hasAnimations: =>
          console.log @collection.where({ visible: true }).length
          @collection.where({ visible: true }).length isnt 0
    initialize: (options)->
      for a in options.animations
        console.log a.keyframe, options.keyframe + 1
        a.visible = (a.link is options.link) and (parseInt(a.keyframe, 10) is parseInt(options.keyframe, 10))
      @collection = new AnimationsCollection options.animations, { element: options.element }
    addAnimation: ->
      link     = @options.link
      keyframe = @options.keyframe
      type = switch link 
        when 'enter' then 'fadeIn'
        when 'process' then 'rotate' 
        when 'leave' then 'fadeOut'
      @collection.addAnimation { link: link, type: type, visible: true, keyframe: keyframe }


