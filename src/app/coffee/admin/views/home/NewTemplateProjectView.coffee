define "views/home/NewTemplateProjectView", [ 
  "marionette"
  "collections/TemplatesCollection"
  "templates/home/new_template_project_item" 
], (Marionette, TemplatesCollection, HomeNewTemplateProjectItemTemplate)->
  NewBlancProjectItem = Marionette.ItemView.extend
    template: HomeNewTemplateProjectItemTemplate
    tagName: "li"
    className: "home_container_project"

  NewTemplateProjectView = Marionette.CollectionView.extend
    childView: NewBlancProjectItem
    tagName: "ul"
    className: "home_container_right"
    initialize: ->
      @collection = new TemplatesCollection()
      @collection.add new @collection.model()