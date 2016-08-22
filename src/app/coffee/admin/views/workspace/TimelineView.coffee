define "views/workspace/TimelineView", [ 
  "marionette"
  "templates/workspace/timeline"
  "templates/workspace/timeline_item"
  "behaviors/MCustomScrollbar"
  "jquery-ui"
  "d3"
  "bootstrap"
], (Marionette, TimelineTemplate, TimelineItemTemplate)->
  TimelineItem = Marionette.ItemView.extend
    template: TimelineItemTemplate
    className: 'timeline_item custom active'
    ui:
      runner: '.timeline_time'
      keyframes: '.timeline_item-keyframe'
      animations: '.timeline-animation'
    events:
      'click .timeline_item-keyframe': 'selectKeyframe'
      'click .timeline-animation': 'selectAnimation'
      'contextmenu .timeline-animation:last-child': 'renderDeleteButton'
      'click .event-remove-animation': 'onDeleteButtonClick'
      'drag .timeline_item-keyframe': 'onDrag'
      'dragstart .timeline_item-keyframe': 'onDragStart'
      'dragstop .timeline_item-keyframe': 'onDragStop'
    modelEvents:
      'sync': 'render'
    initialize: ->
      @active_animations = [  ]
      @active_keyframe   = 0
      @active_animation  = undefined
      @listenTo window.App, 'element:' + @model.get('id') + ':animation:change', @changeAnimation
      @listenTo window.App, 'element:' + @model.get('id') + ':animation:delete', @deleteAnimation
      @listenTo window.App, 'element:' + @model.get('id') + ':keyframe:create', @onKeyframeCreate
      @runner = d3.select @el
      @dragged = false
    renderDeleteButton: (e)->
      if !@dragged
        offset = $(e.target).offset()
        button = $ '''
          <div class="dropdown open">
            <div class="dropdown-menu">
              <div>
                <a href="#" class="event-remove-animation" style="margin-left: 20px;">Удалить колено</a>
              </div>
            </div>
          </div>'''
        button.css { position: 'absolute', top: e.pageY - offset.top - 20, left: e.pageX - offset.left }
        $(e.target).append button

        $(document.body).trigger 'contextmenu_fake'

        $(document.body).on 'click contextmenu contextmenu_fake', _.once (e)-> button.remove()

        e.preventDefault()
        e.stopPropagation()
    onDeleteButtonClick: (e)->
      target = @$el.find('.timeline-animation').last()
      start  = parseInt target.attr('keyframe-start'), 10
      end    = parseInt target.attr('keyframe-end'), 10
      console.log @model.get('id'), start, end
      
      window.App.trigger 'animation:delete', { el: @model.get('id'), start: start, end: end }
      window.App.trigger 'element:' + @model.get('id') + ':animation:delete'
      
      e.preventDefault()
      e.stopPropagation()
    onRender: ->
      @$el.attr 'model-id', @model.get('id')

      @ui.runner.hide()

      @_selectKeyframe(@active_keyframe)
      @_selectAnimation(@active_animation) if @active_animation isnt undefined

      @ui.keyframes
        .draggable
          axis: 'x'
    onAttach: ->
      @render()
    createTransition: (start, end)->
      runner = @ui.runner
      ->
        i = d3.interpolate start*0.12, end*0.12
        (t)-> runner.css({ left: i(t) + 'px' })
    runAll: ->
      keyframes = _.sortBy _.clone(@model.get('keyframes')), (keyframe)-> 
        keyframe.start
      transition = @runner
      runner     = @ui.runner

      for keyframe, i in keyframes
        if keyframes[i + 1] isnt undefined
          start = keyframe.start
          end   = keyframes[i + 1].start

          transition = transition.transition()

          if i is 0 and start isnt 0
            transition.delay start

          transition
            .duration end - start
            .each 'start', -> runner.show()
            .each 'end', -> runner.hide()
            .ease 'linear'
            .tween 'animation-'+i, @createTransition(start, end)
            
        else 
          setTimeout =>
            id = keyframes.length - 1
            @_selectKeyframe id
            window.App.trigger 'element:' + @model.get('id') + ':keyframe:select', { id: id, silent: true }
          , keyframe.start
    playAnimation: (e)->
      data = JSON.parse(e.target.getAttribute('data-animation'))
      window.App.trigger 'element:' + @model.get('id') + ':animation:play', data
      @runAnimation data
    onDrag: (e, ui)->
      keyframe_id = parseInt e.target.getAttribute 'keyframe-id', 10

      ui.position.left = if ui.position.left > -3 then ui.position.left else -3

      x = ui.position.left + 3

      lis = @$el.find 'li'
      kfs = @model.get 'keyframes'
      
      start     = Math.floor x * 8.333333333333334
      old_start = kfs[keyframe_id].start 

      for i in [keyframe_id..kfs.length-1]
        kfs[i].start += start - old_start

        @ui.keyframes[i].style.left = kfs[i].start*0.12-3 + 'px'

        if lis[i] isnt undefined
          lis[i].style.left = kfs[i].start*0.12 + 'px'

      if lis[keyframe_id-1] isnt undefined
        lis[keyframe_id-1].style.width = (start - kfs[keyframe_id-1].start)*0.12 + 'px'

    changeAnimation: (data)->
      @model.set 'animations', data.animations
      @render()
    _selectKeyframe: (id)->
      @active_keyframe = id
      el = @$el.find '[keyframe-id=' + id + ']'
      @ui.keyframes.removeClass 'active'
      el.addClass 'active'  
    _selectAnimation: (data)->
      el = @$el.find('[keyframe-start=' + data.start + ']')

      $('.timeline-animation').removeClass 'active'
      el.addClass 'active'

      window.App.trigger 'element:' + @model.get('id') + ':animation:select', data          
    selectKeyframe: (e)->
      id = e.target.getAttribute 'keyframe-id'

      @_selectKeyframe id

      window.App.trigger 'element:' + @model.get('id') + ':keyframe:select', { id: id }
    onKeyframeCreate: ->
      @active_keyframe = @model.get('keyframes').length - 1
    selectAnimation: (e)->
      # el = $(e.target)

      # @active_animation = 
      #   start: parseInt el.attr('keyframe-start'), 10
      #   end: parseInt el.attr('keyframe-end'), 10
      #   isDeletable: => 
      #     (el.attr('keyframe-start') is @ui.animations.last().attr('keyframe-start')) and (el.attr('keyframe-end') is @ui.animations.last().attr('keyframe-end'))

      # @_selectAnimation @active_animation
    deleteAnimation: ->
      @ui.animations.last().remove()
      deleted_element = @ui.keyframes.last()
      deleted_id = parseInt deleted_element.attr('keyframe-id'), 10
      deleted_element.remove()
      console.log deleted_id, @active_keyframe
      if @active_keyframe is deleted_id
        new_id = deleted_id - 1
        console.log 'oh, no: ', new_id
        @_selectKeyframe new_id
        window.App.trigger 'element:' + @model.get('id') + ':keyframe:select', { id: new_id }
    onDragStop: (e, ui)->
      keyframe_id = e.target.getAttribute 'keyframe-id'
      model_id    = @model.get 'id'

      ui.position.left = if ui.position.left > -3 then ui.position.left else -3
      x = ui.position.left + 3
      
      start = Math.floor x * 8.333333333333334

      window.App.trigger "element:resize", { el: model_id, keyframe: keyframe_id, props: { start: start } }

      @dragged = false
    onDragStart: ->
      @dragged = true
  Marionette.CompositeView.extend
    template: TimelineTemplate
    childView: TimelineItem
    behaviors:
      MCustomScrollbar: { mouseWheel: { invert: true } }
    className: 'timeline'
    childViewContainer: ".bind-timeline-items"
    events:
      'sortstop .bind-timeline-items': 'reOrderElements'
      'dblclick .bind-timeline-items ul': 'createKeyframe'
    onRender: ->
      setTimeout =>
        @$el.find('.bind-timeline-items').sortable
          placeholder: "ui-state-highlight"
          handle: 'img'
          axis: 'y'
        @$el.disableSelection()
      , 0
    playAnimations: ->
      max_duration = 0

      @collection.each (model)->
        keyframes = _.sortBy _.clone(model.get('keyframes')), (keyframe)-> 
          keyframe.start
        window.App.trigger 'element:' + model.get('id') + ':animations:play', { animations: model.get('animations'), keyframes: keyframes }
        max_duration = keyframes[keyframes.length-1].start if keyframes[keyframes.length-1].start > max_duration

      console.log max_duration
      setTimeout =>
        @collection.each (model)->
          window.App.trigger 'element:' + model.get('id') + ':animations:end'
      , max_duration

      @children.each (view)->
        view.runAll()
    initialize: (options)->
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
      
      @collection.trigger 'resort'
    createKeyframe: (e)->
      offset   = $(e.target).offset()
      model_id = e.target.getAttribute 'model-id'

      x = e.pageX - offset.left
      
      start = Math.floor x * 8.333333333333334
      
      window.App.trigger 'element:' + model_id + ':keyframe:create', { start: start } 