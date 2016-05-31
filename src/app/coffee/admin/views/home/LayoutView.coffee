define "views/home/LayoutView", [ 
  "marionette"
  "views/home/HelloView"
  "views/home/NewBlancProjectView"
  "text!html/home/layout.html" 
], (Marionette, HelloView, NewBlancProjectView, HomeLayoutTemplate)->
  HomeLayoutView = Marionette.LayoutView.extend
    template: HomeLayoutTemplate
    regions:
      content: "#content-home"
    showHello: ->
      @showChildView "content", new HelloView()
    showNewBlancProject: ->
      @showChildView "content", new NewBlancProjectView()
