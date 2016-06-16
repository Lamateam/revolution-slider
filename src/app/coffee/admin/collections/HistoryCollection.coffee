define "collections/HistoryCollection", [ 
  "backbone"
  "models/HistoryModel"
], (Backbone, HistoryModel)->
  HistoryCollection = Backbone.Collection.extend
    model: HistoryModel
    addAction: (action)->
      @remove @where { toDelete: true }
      @push action
      @trigger 'action_change'
      @
    undo: ->
      models = @where { toDelete: false }
      model  = models[models.length-1]
      model.set "toDelete", true
      @trigger 'action_change'
      model
    redo: ->
      models = @where { toDelete: true }
      model  = models[0]
      model.set "toDelete", false
      @trigger 'action_change'
      model    
    canUndo: ->
      @where({ toDelete: false }).length > 1
    canRedo: ->
      @where({ toDelete: true }).length isnt 0