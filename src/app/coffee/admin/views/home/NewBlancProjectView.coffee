define "views/home/NewBlancProjectView", [ 
  "marionette"
  "models/ProjectModel"
  "text!html/home/new_blanc_project.html" 
], (Marionette, ProjectModel, HomeNewBlancProjectTemplate)->
  NewBlancProjectView = Marionette.ItemView.extend
    template: HomeNewBlancProjectTemplate
    initialize: ->
      @model = new ProjectModel()