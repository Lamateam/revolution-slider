exports.init = (app)->
  require("./list.coffee").init app
  require("./upload.coffee").init app