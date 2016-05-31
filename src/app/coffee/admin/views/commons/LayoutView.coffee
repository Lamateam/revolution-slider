define "views/commons/LayoutView", [ 
  "marionette"
  "templates/layout" 
], (Marionette, LayoutTemplate)->
  LayoutView = Marionette.LayoutView.extend
    template: LayoutTemplate
    regions:
      content: "#content"
