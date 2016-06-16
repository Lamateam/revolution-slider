define "models/WorkspaceStateModel", [ 
  "backbone"
], (Backbone)->
  WorkspaceStateModel = Backbone.Model.extend
    defaults:
      isNameChange: false
      isElementSelected: false
    clearState: (stateName)->
      @set stateName, false
    clearStates: (stateName)->
      _.each @keys(), (key)=>
        @clearState(key) if @get(key) and (stateName isnt key)
    setState: (stateName, value=true)->
      if @get(stateName) isnt value
        @clearStates stateName
        @set stateName, value
