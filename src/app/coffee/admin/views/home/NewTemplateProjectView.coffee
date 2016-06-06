define "views/home/NewTemplateProjectView", [ 
  "marionette"
  "collections/TemplatesCollection"
  "templates/home/new_template_project" 
  "templates/home/new_template_project_item" 
  "behaviors/MCustomScrollbar"
  "SweetAlert"
], (Marionette, TemplatesCollection, HomeNewTemplateProjectTemplate, HomeNewTemplateProjectItemTemplate, MCustomScrollbarBehavior)->
  NewBlancProjectItem = Marionette.ItemView.extend
    template: HomeNewTemplateProjectItemTemplate
    tagName: "li"
    className: "home_container_project"

  NewTemplateProjectView = Marionette.CompositeView.extend
    childView: NewBlancProjectItem
    childViewContainer: "ul"
    template: HomeNewTemplateProjectTemplate
    className: "home_container_right mcsb-behavior"
    behaviors:
      MCustomScrollbarBehavior: {}
    initialize: ->
      @collection = new TemplatesCollection()
    onShow: ->
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
      @collection.add new @collection.model()
    # onAddChild: ->
    #   console.log "update"
    #   @$el.mCustomScrollbar("update")
