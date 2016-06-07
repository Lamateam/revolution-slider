define "collections/ElementsCollection", [ 
  "backbone"
  "models/ElementModel"
], (Backbone, ElementModel)->
  ElementsCollection = Backbone.Collection.extend
    model: ElementModel