define "views/home/NewBlancProjectView", [ 
  "marionette"
  "models/ProjectModel"
  "templates/home/new_blanc_project" 
], (Marionette, ProjectModel, HomeNewBlancProjectTemplate)->
  NewBlancProjectView = Marionette.ItemView.extend
    template: HomeNewBlancProjectTemplate
    initialize: ->
      @model = new ProjectModel()