define "collections/ElementsCollection", [ 
  "backbone"
  "models/ElementModel"
], (Backbone, ElementModel)->
  ElementsCollection = Backbone.Collection.extend
    url: ->
      "/api/project/" + @project_id + "/" + @slide_id
    model: ElementModel