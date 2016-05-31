define "views/commons/LayoutView", [ 
  "marionette"
  "text!html/layout.html" 
], (Marionette, LayoutTemplate)->
  LayoutView = Marionette.LayoutView.extend
    template: LayoutTemplate
    regions:
      content: "#content"
