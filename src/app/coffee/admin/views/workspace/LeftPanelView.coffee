define "views/workspace/LeftPanelView", [ 
  "marionette"
  "views/workspace/TimelineView"
  "templates/workspace/left_panel"
], (Marionette, TimelineView, WorkspaceLeftPanelTemplate)->
  WorkspaceLeftPanelView = Marionette.ItemView.extend
    className: 'workspace-left_panel'
    ui:
      playBtn: '.bind-play'
    events:
      'click .bind-text-btn': 'onTextButtonClick'
      'click .bind-graph-btn': 'onGraphButtonClick'
      'click .bind-paragraph-btn': 'onParagraphButtonClick'
      'click .bind-play:not(.active)': 'playAnimations'
      # 'click .bind-play.active': 'stopAnimations'
    modelEvents:
      'sync': 'render'
    template: WorkspaceLeftPanelTemplate
    onTextButtonClick: ->
      window.App.trigger "element:create", { 
        type: "text"
        keyframes: [
          {
            start: 0
            props: 
              x: 250
              y: 250
              fill: "000000"
              "font-size": "12px"
              text: "Текст" 
              background_fill: "ffffff"
              angle: 0
          } 
        ]
      }
    onGraphButtonClick: ->
      # window.App.trigger "element:create", { type: "image", props: { x: 100, y: 100, angle: 0, width: 170, height: 200, fill: "rgb(0,0,0)", "xlink:href": "http://fyf.tac-cdn.net/images/products/large/T46-1.jpg" } }
      window.App.trigger "image:create"
    onVideoButtonClick: ->
      window.App.trigger "element:create", { type: "video", props: { x: 100, y: 100, angle: 0, width: 170, height: 200, fill: "rgb(0,0,0)", "xlink:href": "http://fyf.tac-cdn.net/images/products/large/T46-1.jpg" } }
    onParagraphButtonClick: ->
      window.App.trigger "element:create", { type: "text", props: { x: 250, y: 250, fill: "rgb(0,0,0)", "font-size": "12px", texts: "Текст \n Новая строка" } }
    playAnimations: ->
      window.App.trigger "animations:play"
      # @ui.playBtn.addClass 'active'
    stopAnimations: ->
      window.App.trigger "animations:stop"
      @ui.playBtn.removeClass 'active'