define "behaviors/MCustomScrollbar", [ 
  "marionette"
  "mCSB"
], (Marionette)->
  window.Behaviors.MCustomScrollbar = Marionette.Behavior.extend
    initScrollbar: (el)-> el.mCustomScrollbar @options
    destroyScrollbar: (el)-> el.mCustomScrollbar "destroy"
    updateScrollbar: (el)-> el.mCustomScrollbar "destroy"
    initHandler: ->
      if @$el.hasClass "mcsb-behavior"
        @initScrollbar @$el
      el = @$el.find '.mcsb-behavior'
      @initScrollbar(el) if el.length isnt 0
    onAttach: ->
      @initHandler()
    onBeforeDestroy: ->
      if @$el.hasClass "mcsb-behavior"
        @destroyScrollbar @$el
        
      el = @$el.find '.mcsb-behavior'
      @destroyScrollbar(el) if el.length isnt 0
    # onAddChild: ->
    #   if @$el.hasClass "mcsb-behavior"
    #     @updateScrollbar @$el         
      
