define "models/TemplateModel", [ 
  "backbone"
], (Backbone)->
  TemplateModel = Backbone.Model.extend
    defaults:
      name: "Какой-то шаблон"
      pic: "https://ru.yeed.me/system/pictures/images/000/076/098/medium/4730x3605_781737__www.ArtFile.ru_.jpg"
    