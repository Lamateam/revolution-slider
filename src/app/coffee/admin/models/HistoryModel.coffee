define "models/HistoryModel", [ 
  "backbone"
], (Backbone)->
  HistoryModel = Backbone.Model.extend
    defaults:
      el: -1
      action: "none"
      toDelete: false
      options: {}
