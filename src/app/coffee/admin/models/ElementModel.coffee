define "models/ElementModel", [ 
  "backbone"
], (Backbone)->
  ElementModel = Backbone.Model.extend
    urlRoot: ->
      "/api/project/" + @collection.project_id + "/" + @collection.slide_id
    defaults:
      type: "rect"
      props: []
