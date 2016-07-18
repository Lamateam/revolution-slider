define "models/ElementModel", [ 
  "backbone"
], (Backbone)->
  ElementModel = Backbone.Model.extend
    defaults:
      type: "rect"
      isActive: true
      props: {  }
      order: 0
      animations: [  ]
