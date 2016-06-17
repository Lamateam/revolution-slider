define "views/workspace/LeftPanelView", [ 
  "marionette"
  "templates/workspace/left_panel"
], (Marionette, WorkspaceLeftPanelTemplate)->
  WorkspaceLeftPanelView = Marionette.ItemView.extend
    className: 'workspace-left_panel'
    events:
      'click .bind-text-btn': 'onTextButtonClick'
    modelEvents:
      'sync': 'render'
    template: WorkspaceLeftPanelTemplate
    onTextButtonClick: ->
      window.App.trigger "element:create", { type: "text", props: { x: 100, y: 100, fill: "rgb(0,0,0)", "font-size": "12px", text: "Текст" } }
