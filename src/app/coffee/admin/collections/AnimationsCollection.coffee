define "collections/AnimationsCollection", [ 
  "backbone"
  "models/AnimationModel"
], (Backbone, AnimationModel)->
  Backbone.Collection.extend
    comparator: 'id'
    model: AnimationModel
    initialize: (data, @options)->
    addAnimation: (data)->
      data.id = if @length is 0 then 1 else @last().get('id') + 1
      @add data
      window.App.trigger 'animation:add', { model: new AnimationModel(data), element: @options.element }