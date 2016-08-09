define "collections/ImagesCollection", [ 
  "backbone"
], (Backbone)->
  TemplatesCollection = Backbone.Collection.extend
    model: Backbone.Model 
    url: '/api/images/list'