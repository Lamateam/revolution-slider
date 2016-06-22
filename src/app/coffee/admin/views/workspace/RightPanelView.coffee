define "views/workspace/RightPanelView", [ 
  "marionette"
  "templates/workspace/right_panel/project"
  "templates/workspace/right_panel/slydes" 
  "templates/workspace/right_panel/text"  
  "jscolor"
], (Marionette, WorkspaceRightPanelProjectTemplate, WorkspaceRightPanelSlideTemplate, WorkspaceRightPanelTextTemplate)->
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
      element_text: '[name="bind-element_text"]'
      element_texts: '[name="bind-element_texts"]'
      element_font_size: '[name="bind-element_font-size"]'
      element_xlink_href: '[name="bind-element_xlink:href"]'
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
      'blur [name="bind-element_text"]': 'onElementChange'
      'blur [name="bind-element_texts"]': 'onElementChange'
      'blur [name="bind-element_font-size"]': 'onElementChange'
      'blur [name="bind-element_xlink:href"]': 'onElementChange'
    modelEvents:
      'sync': 'render'
    getTemplate: ->
      console.log 'here fetch template'
      res = switch
        when @getOption('type') is 'project' then WorkspaceRightPanelProjectTemplate
        when @getOption('type') is 'slide' then WorkspaceRightPanelSlideTemplate
        when @model.get('type') is 'text' then WorkspaceRightPanelTextTemplate
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
        selection_type: @getOption 'type'
        getHeaderText: (type)->
          switch type
            when 'slide' then "Слайд"
            when 'project' then "Проект"
            when 'element' then "Элемент"
        getLabelText: (type)->
          label = switch type
            when 'x', 'cx' then "X"
            when 'y', 'cy' then "Y"
            when 'fill' then "Заливка"
            when 'width' then "Ширина"
            when 'height' then "Высота"
            when 'r' then "Радиус"
            when 'text', 'texts' then "Текст"
            when 'font-size' then "Размер шрифта"
            when 'angle' then "Поворот"
            when 'xlink:href' then "Ссылка на изображение"
          res = label + ":"
    onElementChange: ->
      data = { el: @model.get('id'), props: {} }
      data.props = switch @model.get('type') 
        when 'circle' then { cx: parseFloat(@ui.element_cx.val(), 10), cy: parseFloat(@ui.element_cy.val(), 10), r: parseFloat(@ui.element_r.val(), 10) } 
        when 'text' 
          _data = { x: parseFloat(@ui.element_x.val(), 10), y: parseFloat(@ui.element_y.val()), "font-size": @ui.element_font_size.val() }
          if @model.get('props').text isnt undefined then _data.text = @ui.element_text.val() else _data.texts = @ui.element_texts.val()
          _data
        when 'rect' then { x: parseFloat(@ui.element_x.val(), 10), y: parseFloat(@ui.element_y.val(), 10), width: parseFloat(@ui.element_width.val(), 10), height: parseFloat(@ui.element_height.val(), 10) }
        when 'image' then { x: parseFloat(@ui.element_x.val(), 10), y: parseFloat(@ui.element_y.val(), 10), width: parseFloat(@ui.element_width.val(), 10), height: parseFloat(@ui.element_height.val(), 10), "xlink:href": @ui.element_xlink_href.val() }
      window.App.trigger "element:change", data
    onSlideChange: ->
      window.App.trigger "slide:change", { id: @model.get('id'), name: @ui.slide_name.val(), duration: @ui.slide_duration.val() }
      
