define "views/workspace/LayoutView", [ 
  "marionette"
  "views/workspace/CanvasView"
  "views/workspace/TopPanelView"
  "templates/workspace/layout" 
], (Marionette, CanvasView, TopPanelView, WorkspaceLayoutTemplate)->
  WorkspaceLayoutView = Marionette.LayoutView.extend
    template: WorkspaceLayoutTemplate
    regions:
      canvas: "#content-canvas"
      top_panel: "#content-top_panel"
      left_panel: "#content-left_panel"
      right_panel: "#content-right_panel"
    renderCanvas: (options)->
      @showChildView "canvas", new CanvasView options
    renderTopPanel: (options)->
      @showChildView "top_panel", new TopPanelView options
      
