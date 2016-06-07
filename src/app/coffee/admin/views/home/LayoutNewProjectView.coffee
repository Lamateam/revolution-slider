define "views/home/LayoutNewProjectView", [ 
  "marionette"
  "views/home/NewBlancProjectView"
  "views/home/NewTemplateProjectView"
  "templates/home/new_project_layout" 
], (Marionette, NewBlancProjectView, NewTemplateProjectView, LayoutNewProjectViewTemplate)->
  LayoutNewProjectView = Marionette.LayoutView.extend
    template: LayoutNewProjectViewTemplate
    ui:
      all_li: "ul.bind-menu li"
      blanc_li: ".bind-menu .bind-blanc"
      template_li: ".bind-menu .bind-template"
      my_li: ".bind-menu .bind-my"
    regions:
      content: "#content-home-project"
    toggleActiveLi: (li)->
      @ui.all_li.removeClass "active"
      li.addClass "active"
    showNewBlancProject: (options)->
      console.log options
      view = new NewBlancProjectView(options)
      @showChildView "content", view
      @toggleActiveLi @ui.blanc_li
      view
    showNewTemplateProject: ->
      view = new NewTemplateProjectView()
      @showChildView "content", view
      @toggleActiveLi @ui.template_li
      view
