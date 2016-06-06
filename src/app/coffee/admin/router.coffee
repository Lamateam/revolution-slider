define "admin/router", [ 
  "marionette"
  "controllers/commons/LayoutController" 
], (Marionette, LayoutController)->
  router = Marionette.AppRouter.extend
    controller: new LayoutController()
    appRoutes: 
      "": "goToHello"
      "home/hello": "home_hello"
      "home/new_blanc_project": "home_new_blanc_project"
      "home/new_template_project": "home_new_template_project"
      "workspace": "workspace"