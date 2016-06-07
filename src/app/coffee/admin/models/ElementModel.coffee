define "models/ElementModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    defaults:
      color: "#000000"
      x: 0
      y: 0
