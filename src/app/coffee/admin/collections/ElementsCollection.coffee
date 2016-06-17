define "collections/ElementsCollection", [ 
  "backbone"
  "models/ElementModel"
], (Backbone, ElementModel)->
  ElementsCollection = Backbone.Collection.extend
    comparator: 'id'
    url: ->
      "/api/project/" + @project_id + "/" + @slide_id
    model: ElementModel
    addElement: (data)->
      model = new ElementModel data
      @add model
      model.save()