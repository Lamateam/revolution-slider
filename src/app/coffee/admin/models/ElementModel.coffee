define "models/ElementModel", [ 
  "backbone"
], (Backbone)->
  ElementModel = Backbone.Model.extend
    defaults:
      type: "rect"
      isActive: true
      props: []
