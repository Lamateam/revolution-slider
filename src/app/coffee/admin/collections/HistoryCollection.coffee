define "collections/HistoryCollection", [ 
  "backbone"
  "models/HistoryModel"
], (Backbone, HistoryModel)->
  HistoryCollection = Backbone.Collection.extend
    model: HistoryModel
    addAction: (action)->
      @remove @where { toDelete: true }
      @push action
    undo: ->
      models = @where { toDelete: false }
      model  = models[models.length-1]
      model.set "toDelete", true
      model
    redo: ->
      models = @where { toDelete: true }
      model  = models[0]
      model.set "toDelete", false
      model    
    canUndo: ->
      @where({ toDelete: false }).length > 1
    canRedo: ->
      @where({ toDelete: true }).length isnt 0