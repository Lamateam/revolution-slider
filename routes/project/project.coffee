projects = []
exports.init = (app)->
  app.get "/api/project/:id", (req, res, next)->
    res.send projects[req.params.id]

  app.post "/api/project/", (req, res, next)->
    req.body.id         = projects.length
    req.body.slides = [
      {
        id: 0
        name: "Новый слайд"
        duration: 3
        background: "ffffff"
        repeat: 'no-repeat'
        repeatNum: 1
        animations: []
        elements: [ 
          { 
            id: 0
            order: 1
            type: "rect"
            animations: []
            keyframes: [
              {
                start: 0
                props: { fill: "ff0000", x: 100, y: 100, angle: 30, width: 100, height: 100, 'fill-opacity': 1 }
              }
            ] 
          }
          { 
            id: 1
            order: 0
            type: "rect"
            animations: []
            keyframes: [
              {
                start: 0
                props: { fill: "ff0000", x: 0, y: 0, angle: 0, width: 100, height: 100, 'fill-opacity': 1 } 
              }
            ]
          }
        ]
      }
    ]
    projects.push req.body
    res.send req.body

  app.patch "/api/project/:id", (req, res, next)->
    project = projects[req.params.id]
    project[key] = value for own key, value of req.body
    res.send project

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

  app.get '/api/project/:id/export', (req, res, next)->
    project = projects[req.params.id]

    res.render "client/index", { project: JSON.stringify(project) }