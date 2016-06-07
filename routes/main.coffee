exports.init = (app)->
  require("./static/main.coffee").init app
  require("./project/main.coffee").init app

    