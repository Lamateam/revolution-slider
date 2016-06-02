define "overwrites/behaviors", ->
  (Marionette)->
    window.Behaviors = {} if window.Behaviors is undefined
    Marionette.Behaviors.behaviorsLookup = ->
      window.Behaviors