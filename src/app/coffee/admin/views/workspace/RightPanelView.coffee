define "views/workspace/RightPanelView", [ 
  "marionette"
  "templates/workspace/right_panel" 
  "jscolor"
], (Marionette, WorkspaceRightPanelTemplate)->
  WorkspaceRightPanelView = Marionette.ItemView.extend
    className: 'workspace-right_panel'
    ui:
      slide_name: '.bind-slide_name'
      slide_duration: '.bind-slide_duration'
      element_x: '[name="bind-element_x"]'
      element_y: '[name="bind-element_y"]'
      element_r: '[name="bind-element_r"]'
      element_cx: '[name="bind-element_cx"]'
      element_cy: '[name="bind-element_cy"]'
      element_width: '[name="bind-element_width"]'
      element_height: '[name="bind-element_height"]'
      element_fill: '[name="bind-element_fill"]'
    events:
      'blur .bind-slide_name': 'onSlideChange'
      'blur .bind-slide_duration': 'onSlideChange'
      'blur [name="bind-element_x"]': 'onElementChange'
      'blur [name="bind-element_y"]': 'onElementChange'
      'blur [name="bind-element_cx"]': 'onElementChange'
      'blur [name="bind-element_cy"]': 'onElementChange'
      'blur [name="bind-element_width"]': 'onElementChange'
      'blur [name="bind-element_height"]': 'onElementChange'
      'blur [name="bind-element_r"]': 'onElementChange'
    modelEvents:
      'sync': 'render'
    template: WorkspaceRightPanelTemplate
    onShow: ->
      console.log "show right panel"
      @initPicker()
    onRender: ->
      console.log "render right panel"
      @initPicker()
    initPicker: ->
      onFillChange = @onFillChange.bind @
      picker       = new jscolor @ui.element_fill[0] if @ui.element_fill.length isnt 0      
      @ui.element_fill.on 'blur', _.once ->
        onFillChange picker
    onFillChange: (picker)->
      data = { el: @model.get('id'), props: { fill: picker.toRGBString() } }
      window.App.trigger "element:change", data
    templateHelpers: ->
      res = 
        type: @getOption 'type'
        getHeaderText: (type)->
          switch type
            when 'slide' then "Слайд"
            when 'element' then "Элемент"
        getLabelText: (type)->
          label = switch type
            when 'x', 'cx' then "X"
            when 'y', 'cy' then "Y"
            when 'fill' then "Заливка"
            when 'width' then "Ширина"
            when 'height' then "Высота"
            when 'r' then "Радиус"
          res = label + ":"
    onElementChange: ->
      data = { el: @model.get('id'), props: {} }
      data.props = if @model.get('type') is 'circle' then { cx: @ui.element_cx.val(), cy: @ui.element_cy.val(), r: @ui.element_r.val() } else { x: @ui.element_x.val(), y: @ui.element_y.val(), width: @ui.element_width.val(), height: @ui.element_height.val() }
      window.App.trigger "element:change", data
    onSlideChange: ->
      window.App.trigger "slide:change", { id: @model.get('id'), name: @ui.slide_name.val(), duration: @ui.slide_duration.val() }
      
