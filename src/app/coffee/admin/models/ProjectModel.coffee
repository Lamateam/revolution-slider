define "models/ProjectModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    defaults:
      name: "Новый проект"
      dim: "4x3"
