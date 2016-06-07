define "views/home/LayoutView", [ 
  "marionette"
  "views/home/HelloView"
  "views/home/LayoutNewProjectView"
  "templates/home/layout" 
], (Marionette, HelloView, LayoutNewProjectView, HomeLayoutTemplate)->
  HomeLayoutView = Marionette.LayoutView.extend
    template: HomeLayoutTemplate
    regions:
      content: "#content-home"
    setCurrent: (SomeClass)->
      if !(@currentView instanceof SomeClass)
        @currentView = new SomeClass()
        @showChildView "content", @currentView
    showHello: ->
      @setCurrent HelloView
    showNewBlancProject: (options)->
      @setCurrent LayoutNewProjectView
      @currentView.showNewBlancProject(options)
    showNewTemplateProject: ->
      @setCurrent LayoutNewProjectView
      @currentView.showNewTemplateProject()
