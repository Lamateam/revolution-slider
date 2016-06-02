define "views/home/LayoutNewProjectView", [ 
  "marionette"
  "views/home/NewBlancProjectView"
  "views/home/NewTemplateProjectView"
  "templates/home/new_project_layout" 
], (Marionette, NewBlancProjectView, NewTemplateProjectView, LayoutNewProjectViewTemplate)->
  LayoutNewProjectView = Marionette.LayoutView.extend
    template: LayoutNewProjectViewTemplate
    ui:
      menu: "ul.bind-menu"
      blanc_li: ".bind-menu .bind-blanc"
      template_li: ".bind-menu .bind-template"
      my_li: ".bind-menu .bind-my"
    regions:
      content: "#content-home-project"
    toggleActiveLi: (li)->
      @ui.menu.find("li").removeClass "active"
      li.addClass "active"
    showNewBlancProject: ->
      @showChildView "content", new NewBlancProjectView()
      @toggleActiveLi @ui.blanc_li
    showNewTemplateProject: ->
      @showChildView "content", new NewTemplateProjectView()
      @toggleActiveLi @ui.template_li
