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
    changeDuration: (e)->
      duration = parseInt e.target.value, 10
      @model.collection.changeAnimation @model.get('id'), { duration: duration }
    onRender: ->
      @$el.hide() if !@model.get('visible')
  Marionette.CompositeView.extend
    template: AnimationsTemplate
    childView: AnimationItem
    childViewContainer: ".bind-animations"
    events:
      'click .bind-add-animation': 'addAnimation'
    initialize: (options)->
      for a in options.animations
        a.visible = a.link is options.link
      @collection = new AnimationsCollection options.animations, { element: options.element }
    addAnimation: ->
      link = @options.link
      type = switch link 
        when 'enter' then 'fadeIn'
        when 'process' then 'rotate' 
        when 'leave' then 'fadeOut'
      @collection.addAnimation { link: link, type: type, visible: true }


