define "collections/AnimationsCollection", [ 
  "backbone"
  "models/AnimationModel"
], (Backbone, AnimationModel)->

  leave_queue = [ 'enter', 'process', 'leave' ]

  Backbone.Collection.extend
    comparator: 'keyframe'
    model: AnimationModel
    initialize: (data, @options)->
    changeAnimation: (id, data)->
      window.App.trigger 'animation:change', { id: id, element: @options.element, data: data }
    addAnimation: (data)->
      data.id = if @length is 0 then 1 else @last().get('id') + 1

      animations = [  ]

      animations.push (new AnimationModel(data)).toJSON()

      console.log data

      window.App.trigger 'animations:change', { element: @options.element, animations: animations }

      # @add data

      # window.App.trigger 'animation:add', { model: new AnimationModel(data), element: @options.element }