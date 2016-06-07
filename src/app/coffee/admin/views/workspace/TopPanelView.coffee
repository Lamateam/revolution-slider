define "views/workspace/TopPanelView", [ 
  "marionette"
  "templates/workspace/top_panel" 
], (Marionette, WorkspaceTopPanelTemplate)->
  WorkspaceLayoutView = Marionette.ItemView.extend
    template: WorkspaceTopPanelTemplate
    templateHelpers:
      getSlidesPostfix: (count)->
        res = switch
          when count is 1 then "слайд"
          when (count > 1) and (count < 5) then "слайда"
          when true then "слайдов"
      
