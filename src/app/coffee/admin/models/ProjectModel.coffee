define "models/ProjectModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    urlRoot: "/api/project/"
    defaults:
      name: ""
      dim: "4x3"
