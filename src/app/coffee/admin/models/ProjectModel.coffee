define "models/ProjectModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    defaults:
      name: ""
      dim: "4x3"
