define "views/home/HelloView", [ 
  "marionette"
  "text!html/home/hello.html" 
], (Marionette, HomeHelloTemplate)->
  HomeHelloView = Marionette.ItemView.extend
    template: HomeHelloTemplate
