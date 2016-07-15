define "views/workspace/LayoutView", [ 
  "marionette"
  "views/workspace/CanvasView"
  "views/workspace/TopPanelView"
  "views/workspace/RightPanelView"
  "views/workspace/LeftPanelView"
  "views/workspace/UploadImageView"
  "views/workspace/UploadEditImageView"
  "templates/workspace/layout" 
], (Marionette, CanvasView, TopPanelView, RightPanelView, LeftPanelView, UploadImageView, UploadEditImageView, WorkspaceLayoutTemplate)->
  WorkspaceLayoutView = Marionette.LayoutView.extend
    template: WorkspaceLayoutTemplate
    regions:
      canvas: "#content-canvas"
      top_panel: "#content-top_panel"
      left_panel: "#content-left_panel"
      right_panel: "#content-right_panel"
      popup: "#popup"
    renderCanvas: (options)->
      @showChildView "canvas", new CanvasView options
    renderTopPanel: (options)->
      @showChildView "top_panel", new TopPanelView options
    renderRightPanel: (options)->
      @showChildView "right_panel", new RightPanelView options
    renderLeftPanel: (options)->
      @showChildView "left_panel", new LeftPanelView options
    renderUploadImage: (options)->
      @showChildView "popup", new UploadImageView options
    renderUploadEditImage: (options)->
      @showChildView "popup", new UploadEditImageView options
      
