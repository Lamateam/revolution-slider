define "models/ProjectModel", [ 
  "backbone"
], (Backbone)->
  ProjectModel = Backbone.Model.extend
    urlRoot: "/api/project/"
    defaults:
      name: ""
      dim: "4x3"
      repeat: 'no-repeat'
      repeatNum: 1
      disableSound: false
      animations: []
