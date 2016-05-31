define "models/ProjectModel", [ 
  "marionette"
], (Marionette)->
  ProjectModel = Backbone.Model.extend
    defaults:
      name: "Новый проект"
