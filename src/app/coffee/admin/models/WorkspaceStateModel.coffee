define "models/WorkspaceStateModel", [ 
  "backbone"
], (Backbone)->
  WorkspaceStateModel = Backbone.Model.extend
    defaults:
      isNameChange: false
    clearState: (stateName)->
      @set stateName, false
    clearStates: ->
      _.each @keys(), (key)=>
        @clearState(key) if @get key
    setState: (stateName)->
      if !@get stateName
        @clearStates()
        @set stateName, true
