projects = []
exports.init = (app)->
  app.get "/api/project/:id", (req, res, next)->
    res.send projects[req.params.id]

  app.post "/api/project/", (req, res, next)->
    projects.push req.body
    req.body.id = projects.length - 1
    req.body.slides = [{id: 0, name: "Новый слайд", duration: 3, elements: [ 
      { id: 0, type: "rect", props: { fill: "rgb(255,0,0)", x: 100, y: 100, angle: 30, width: 100, height: 100 } }
      # { id: 1, type: "circle", props: { fill: "rgb(255,255,0)", cx: 50, cy: 50, r: 100 } } 
      { id: 1, type: "rect", props: { fill: "rgb(255,0,0)", x: 0, y: 0, angle: 0, width: 100, height: 100 } }
    ]}]
    res.send req.body

  app.patch "/api/project/:id", (req, res, next)->
    p = projects[req.params.id]
    p[key] = value for own key, value of req.body
    res.send p

  app.patch "/api/project/:project_id/:id/", (req, res, next)->
    slide = projects[req.params.project_id].slides[req.params.id]
    slide[key] = value for own key, value of req.body
    res.send slide

  app.put "/api/project/:project_id/:slide_id/:id", (req, res, next)->
    elements = projects[req.params.project_id].slides[req.params.slide_id].elements
    elements.push req.body
    res.send req.body
  app.patch "/api/project/:project_id/:slide_id/:id", (req, res, next)->
    el = projects[req.params.project_id].slides[req.params.slide_id].elements[req.params.id]
    el[key] = value for own key, value of req.body
    res.send el