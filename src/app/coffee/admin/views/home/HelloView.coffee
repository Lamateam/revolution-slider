define "views/home/HelloView", [ 
  "marionette"
  "templates/home/hello" 
], (Marionette, HomeHelloTemplate)->
  HelloView = Marionette.ItemView.extend
    template: HomeHelloTemplate
