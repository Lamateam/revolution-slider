define "admin/router", [ 
  "marionette"
  "controllers/commons/LayoutController" 
], (Marionette, LayoutController)->
  router = Marionette.AppRouter.extend
    controller: new LayoutController()
    appRoutes: 
      "": "home"
      "home/new_blanc_project": "home_new_blanc_project"