define "models/SlideModel", [ 
  "backbone"
], (Backbone)->
  SlideModel = Backbone.Model.extend
    urlRoot: ->
      "/api/project/" + @project_id
    defaults:
      name: "Новый слайд"
      duration: 3
      elements: []
