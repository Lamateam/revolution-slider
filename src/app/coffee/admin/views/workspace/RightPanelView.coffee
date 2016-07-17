define "views/workspace/RightPanelView", [ 
  "marionette"
  "views/workspace/AnimationsView"
  "templates/workspace/right_panel/project"
  "templates/workspace/right_panel/slydes" 
  "templates/workspace/right_panel/text" 
  "templates/workspace/right_panel/paragraph"
  "templates/workspace/right_panel/date"
  "templates/workspace/right_panel/graphics"
  "templates/workspace/right_panel/shape"
  "templates/workspace/right_panel/time"
  "templates/workspace/right_panel/video"
  "templates/workspace/right_panel/weather"
  "behaviors/PreventDefaultStopPropagation"
  "behaviors/MCustomScrollbar" 
  "jscolor"
], (Marionette, AnimationsView, WorkspaceRightPanelProjectTemplate, WorkspaceRightPanelSlideTemplate, WorkspaceRightPanelTextTemplate, WorkspaceRightPanelParagraphTemplate, WorkspaceRightPanelDateTemplate, WorkspaceRightPanelGraphicsTemplate, WorkspaceRightPanelShapeTemplate, WorkspaceRightPanelTimeTemplate, WorkspaceRightPanelVideoTemplate, WorkspaceRightPanelWeatherTemplate)->
  Marionette.ItemView.extend
    className: 'workspace-right_panel mcsb-behavior'
    behaviors:
      MCustomScrollbar: { scrollbarPosition: 'outside' }
      PreventDefaultStopPropagation: {  }
    modelEvents: { sync: 'render' }
    ui:
      set_color: '.set_color'
      # WorkspaceRightPanelProjectTemplate ui
      repeat_num: '[name="repeatNum"]'
    events:
      'blur input[type="text"].bind-props': 'onInputPropsChange'
      'blur input[type="text"].bind': 'onInputChange'
      'change input[type="radio"].bind': 'onInputChange'
      'change input[type="radio"].bind-props': 'onInputPropsChange'
      'change input[type="checkbox"].bind': 'onInputChange'
      'change input[type="checkbox"].bind-props': 'onInputPropsChange'
      'change select.bind-props': 'onInputPropsChange'
      'change textarea.bind-props': 'onInputPropsChange'
      # WorkspaceRightPanelGraphicsTemplate handlers
      'click .bind-image-loading': 'onImageLoadingClick'
      # WorkspaceRightPanelProjectTemplate handlers
      'change input[name="repeat"]': 'onRepeatChange'
      # WorkspaceRightPanelSlideTemplate handlers
      'change #set_slide_input': 'onInputChange'
      # WorkspaceRightPanelTextTemplate handlers
      # 'change #set_text_input': 'onInputPropsChange'
    getTemplate: ->
      res = switch @getOption('type')
        when 'project' then WorkspaceRightPanelProjectTemplate
        when 'slide' then WorkspaceRightPanelSlideTemplate
        when 'element'
          switch @model.get('type')
            when 'text' 
              if @model.get('props').text isnt undefined then WorkspaceRightPanelTextTemplate else WorkspaceRightPanelParagraphTemplate
            when 'date' then WorkspaceRightPanelDateTemplate
            when 'image' then WorkspaceRightPanelGraphicsTemplate
            when 'rect' then WorkspaceRightPanelShapeTemplate
            when 'circle' then WorkspaceRightPanelShapeTemplate
    onRender: ->
      @initPicker()
      setTimeout =>
        manager = new Marionette.RegionManager
          regions:
            animationsEnterRegion: '#animations_enter'
            animationsLeaveRegion: '#animations_leave'

        manager.get('animationsEnterRegion').show new AnimationsView
          link: 'enter'
          animations: @model.get 'animations'
          element: { type: @getOption('type'), id: @model.get('id') } 
        
        manager.get('animationsLeaveRegion').show new AnimationsView
          link: 'leave'
          animations: @model.get 'animations'
          element: { type: @getOption('type'), id: @model.get('id') } 

        if @$el.find('#animations_process').length isnt 0
          manager.addRegion "animationsProcessRegion", '#animations_process'
          manager.get('animationsProcessRegion').show new AnimationsView
            link: 'process'
            animations: @model.get 'animations'
            element: { type: @getOption('type'), id: @model.get('id') }

      , 0
    initPicker: ->
      for el in @ui.set_color
        new jscolor(el, { valueElement: @$el.find('#' + el.getAttribute('data-valueelement'))[0], styleElement: @$el.find('#' + el.getAttribute('data-styleelement'))[0] })
    getDataFromInput: (target)->
      el = $(target)
      field = el.attr 'bind-to'
      value = el.val()

      value = parseFloat(value, 10) if target.hasAttribute 'parse-float'
      value = parseInt(value, 10) if target.hasAttribute 'parse-int'

      value = target.checked if el.attr('type') is 'checkbox'

      data  = {  }

      data[field] = value

      data      
    onInputPropsChange: (e)-> window.App.trigger "element:change", { el: @model.get('id'), props: @getDataFromInput(e.target) }
    onInputChange: (e)-> window.App.trigger @getOption('type') + ":update", @getDataFromInput(e.target)
    # WorkspaceRightPanelGraphicsTemplate handlers
    onImageLoadingClick: -> window.App.trigger "image:edit", { id: @model.get 'id' }
    # WorkspaceRightPanelProjectTemplate handlers
    onRepeatChange: (e)->
      value = $(e.target).val()
      if value is 'repeat'
        @ui.repeat_num
          .removeClass 'disabled'
          .removeAttr 'disabled'
      else
        @ui.repeat_num
          .addClass 'disabled'
          .attr 'disabled', true
