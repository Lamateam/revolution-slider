define "views/home/NewBlancProjectView", [ 
  "marionette"
  "behaviors/PreventDefaultStopPropagation"
  "templates/home/new_blanc_project" 
], (Marionette, PreventDefaultStopPropagation, HomeNewBlancProjectTemplate)->
  NewBlancProjectView = Marionette.ItemView.extend
    template: HomeNewBlancProjectTemplate
    ui:
      name: 'input[name="name"]'
      dim: 'input[name="dim"]'
    behaviors:
      PreventDefaultStopPropagation: {}
    onSubmit: ->
      res = 
        name: @ui.name.val()
        dim: @ui.dim.filter(":checked").val()
      if res.name.length is 0 then @error() else window.App.trigger "project:create", res
