exports.init = (app)->
  app.get "/", (req, res, next)->
    res.render "index", res.locals