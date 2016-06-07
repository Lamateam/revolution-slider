define "behaviors/MCustomScrollbar", [ 
  "marionette"
  "mCSB"
], (Marionette)->
  window.Behaviors.MCustomScrollbar = Marionette.Behavior.extend
    initScrollbar: (el)->
      el.mCustomScrollbar()
    destroyScrollbar: (el)->
      el.mCustomScrollbar "destroy"
    updateScrollbar: (el)->
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
      
