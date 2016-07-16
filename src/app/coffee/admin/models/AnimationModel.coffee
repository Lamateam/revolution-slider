define "models/AnimationModel", [ 
  "backbone"
], (Backbone)->
  Backbone.Model.extend
    defaults:
      type: 'fadeIn'
      duration: 500
      effect: 'ease'
      link: 'enter'
      start: 0

