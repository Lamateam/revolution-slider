define "views/commons/PopoverError", [ 
  "marionette"
  "templates/commons/popover_error" 
], (Marionette, PopoverErrorTemplate)->
  PopoverError = Marionette.ItemView.extend
    template: PopoverErrorTemplate
