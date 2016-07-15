define "views/workspace/AnimationsView", [ 
  "marionette"
  "collections/AnimationsCollection"
  "templates/workspace/animations"
  "templates/workspace/animations_item"
], (Marionette, AnimationsCollection, AnimationsTemplate, AnimationsItemTemplate)->
  AnimationItem = Marionette.ItemView.extend
    template: AnimationsItemTemplate
  Marionette.CompositeView.extend
    template: AnimationsTemplate
    childView: AnimationItem
    childViewContainer: ".bind-animations"
    modelEvents:
      'change': 'render'
    events:
      'click .bind-add-animation': 'addAnimation'
    initialize: (options)->
      filtered = []
      for a in options.animations
        filtered.push(a) if a.link is options.link
      @collection = new AnimationsCollection filtered, { element: options.element }
      console.log 'options: ', options
    addAnimation: ->
      link = @options.link
      type = switch link 
        when 'enter' then 'fadeIn'
        when 'process' then 'rotate' 
        when 'leave' then 'fadeOut'
      @collection.addAnimation { link: link, type: type }


