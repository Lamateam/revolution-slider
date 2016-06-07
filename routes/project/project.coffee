projects = []
exports.init = (app)->
  app.get "/api/project/:id", (req, res, next)->
    res.send projects[req.params.id]

  app.post "/api/project/", (req, res, next)->
    projects.push req.body
    req.body.id = projects.length - 1
    req.body.slides = []
    res.send req.body