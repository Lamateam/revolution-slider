define "collections/TemplatesCollection", [ 
  "backbone"
  "models/TemplateModel"
], (Backbone, TemplateModel)->
  TemplatesCollection = Backbone.Collection.extend
    model: TemplateModel