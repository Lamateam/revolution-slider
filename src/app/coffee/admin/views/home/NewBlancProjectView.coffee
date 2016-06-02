define "views/home/NewBlancProjectView", [ 
  "marionette"
  "models/ProjectModel"
  "behaviors/PreventDefaultStopPropagation"
  "templates/home/new_blanc_project" 
], (Marionette, ProjectModel, PreventDefaultStopPropagation, HomeNewBlancProjectTemplate)->
  NewBlancProjectView = Marionette.ItemView.extend
    template: HomeNewBlancProjectTemplate
    ui:
      name: 'input[name="name"]'
      dim: 'input[name="dim"]'
    behaviors:
      PreventDefaultStopPropagation:
        submit: 
          prefix: "Form"
    initialize: ->
      @model = new ProjectModel()
    onSubmitForm: ->
      console.log @ui