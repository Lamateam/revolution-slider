define "behaviors/PreventDefaultStopPropagation", [ 
  "marionette"
  "overwrites/behaviors"
], (Marionette, BehaviorsOverWrite)->
  window.Behaviors.PreventDefaultStopPropagation = Marionette.Behavior.extend
    events:
      "click .pd-click-behavior": "preventDefaultClick"
      "click .sp-click-behavior": "stopPropagationClick"
      "submit .pd-submit-behavior": "preventDefaultSubmit"
      "submit .sp-submit-behavior": "stopPropagationSubmit"
    preventDefaultClick: (e)->
      e.preventDefault()
      Marionette.triggerMethodOn @view, "click" + (if (@options.click is undefined) or (@options.click.prefix is undefined) then "" else @options.click.prefix), e
    stopPropagationClick: (e)->
      e.stopPropagation()
    preventDefaultSubmit: (e)->
      e.preventDefault()
      arr = e.target.className.match /pd-submit-behavior-prefix-([A-Za-z]+)/i
      prefix = if arr then arr[1] else ""
      Marionette.triggerMethodOn @view, "submit" + prefix, e
    stopPropagationSubmit: (e)->
      e.stopPropagation()
      
