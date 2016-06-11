define "views/workspace/TopPanelView", [ 
  "marionette"
  "templates/workspace/top_panel" 
], (Marionette, WorkspaceTopPanelTemplate)->
  WorkspaceLayoutView = Marionette.ItemView.extend
    template: WorkspaceTopPanelTemplate
    ui:
      "name_change": ".bind-name_change"
    events: 
      "blur .bind-name_change": "onBlurNameChange"
      "click .bind-name": "onNameClick"
      "click .bind-undo": "onUndoClick"
      "click .bind-redo": "onRedoClick"
      "click .bind-preview": "onPreviewClick"
      "click .bind-download": "onDownloadClick"
    onNameClick: ->
      window.App.trigger "workspace:name"
    onUndoClick: ->
      window.App.trigger "workspace:undo"
    onRedoClick: ->
      window.App.trigger "workspace:redo"
    onPreviewClick: ->
      window.App.trigger "workspace:preview"
    onDownloadClick: ->
      window.App.trigger "workspace:download"
    onBlurNameChange: ->
      val = @ui.name_change.val()
      if val.length is 0 then @error() else window.App.trigger "project:update", {name: val}
    templateHelpers: ->
      res = 
        isNameChange: =>
          console.log "here render"
          @getOption('stateModel').get "isNameChange"
        getSlidesPostfix: (count)->
          res = switch
            when count is 1 then "слайд"
            when (count > 1) and (count < 5) then "слайда"
            when true then "слайдов"
    initialize: (opt)->
      @listenTo opt.stateModel, "change", @render
      
