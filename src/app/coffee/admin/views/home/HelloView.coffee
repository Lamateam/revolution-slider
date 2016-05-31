define "views/home/HelloView", [ 
  "marionette"
  "templates/home/hello" 
], (Marionette, HomeHelloTemplate)->
  HomeHelloView = Marionette.ItemView.extend
    template: HomeHelloTemplate
