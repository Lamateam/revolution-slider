define "models/ElementModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    defaults:
      x: 0
      y: 0
      props: []
