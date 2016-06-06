define "behaviors/PreventDefaultStopPropagation", [ 
  "marionette"
  "overwrites/behaviors"
  "mCSB"
], (Marionette, BehaviorsOverWrite)->
  window.Behaviors.MCustomScrollbarBehavior = Marionette.Behavior.extend
    initScrollbar: (el)->
      console.log "here", el
      el.mCustomScrollbar()
    destroyScrollbar: (el)->
      console.log "hide"
      el.mCustomScrollbar "destroy"
    updateScrollbar: (el)->
      console.log "update"
      el.mCustomScrollbar "destroy"
    onShow: ->
      if @$el.hasClass "mcsb-behavior"
        @initScrollbar @$el
    onBeforeDestroy: ->
      if @$el.hasClass "mcsb-behavior"
        @destroyScrollbar @$el
    onAddChild: ->
      if @$el.hasClass "mcsb-behavior"
        @updateScrollbar @$el         
      
