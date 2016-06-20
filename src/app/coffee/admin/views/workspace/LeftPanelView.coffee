define "views/workspace/LeftPanelView", [ 
  "marionette"
  "templates/workspace/left_panel"
], (Marionette, WorkspaceLeftPanelTemplate)->
  WorkspaceLeftPanelView = Marionette.ItemView.extend
    className: 'workspace-left_panel'
    events:
      'click .bind-text-btn': 'onTextButtonClick'
      'click .bind-graph-btn': 'onGraphButtonClick'
    modelEvents:
      'sync': 'render'
    template: WorkspaceLeftPanelTemplate
    onTextButtonClick: ->
      window.App.trigger "element:create", { type: "text", props: { x: 250, y: 250, fill: "rgb(0,0,0)", "font-size": "12px", text: "Текст" } }
    onGraphButtonClick: ->
      window.App.trigger "element:create", { type: "image", props: { x: 100, y: 100, angle: 0, width: 170, height: 200, fill: "rgb(0,0,0)", "xlink:href": "http://fyf.tac-cdn.net/images/products/large/T46-1.jpg" } }