define "collections/AnimationsCollection", [ 
  "backbone"
  "models/AnimationModel"
], (Backbone, AnimationModel)->

  leave_queue = [ 'enter', 'process', 'leave' ]

  Backbone.Collection.extend
    comparator: 'id'
    model: AnimationModel
    initialize: (data, @options)->
    changeAnimation: (id, data)->
      window.App.trigger 'animation:change', { id: id, element: @options.element, data: data }
    addAnimation: (data)->
      data.id = if @length is 0 then 1 else @last().get('id') + 1

      animations = [  ]
      
      start = 0
      @each (model)=>
        link     = model.get 'link'
        duration = model.get 'duration'
        if (link is data.link) or (leave_queue.indexOf(link) < leave_queue.indexOf(data.link))
          start += duration

      @each (model)=>
        link     = model.get 'link'
        duration = model.get 'duration'        
        if leave_queue.indexOf(link) > leave_queue.indexOf(data.link)
          _data = { start: model.get('start') + 500 }
          animations.push { id: model.get('id'), data: _data }
          # window.App.trigger 'animation:change', { id: model.get('id'), element: @options.element, data: data }

      data.start = start

      animations.push (new AnimationModel(data)).toJSON()

      window.App.trigger 'animations:change', { element: @options.element, animations: animations }

      # @add data

      # window.App.trigger 'animation:add', { model: new AnimationModel(data), element: @options.element }