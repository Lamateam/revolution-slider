fs       = require 'fs'
archiver = require 'archiver'

copyFileSync = (srcFile, destFile) ->
  BUF_LENGTH = 64*1024
  buff = new Buffer(BUF_LENGTH)
  fdr = fs.openSync(srcFile, 'r')
  fdw = fs.openSync(destFile, 'w')
  bytesRead = 1
  pos = 0
  while bytesRead > 0
    bytesRead = fs.readSync(fdr, buff, 0, BUF_LENGTH, pos)
    fs.writeSync(fdw,buff,0,bytesRead)
    pos += bytesRead
  fs.closeSync(fdr)
  fs.closeSync(fdw)

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

  app.get '/api/project/:id/preview', (req, res, next)->
    project = projects[req.params.id]

    res.render "client/index", { project: JSON.stringify(project) }

  app.get '/api/project/:id/export', (req, res, next)->
    project = projects[req.params.id]

    app.render "client/index", { project: JSON.stringify(project) }, (err, html)->
      tmp_folder = fs.mkdtempSync 'tmp/project-'
      console.log tmp_folder, err
      fs.writeFileSync tmp_folder + '/index.html', html.replace /\/static\//gi, ''
      
      uploaded_images_folder = tmp_folder + '/uploaded_images'
      fs.mkdirSync uploaded_images_folder

      for slide in project.slides
        for element in slide.elements
          console.log element.type, element.keyframes[0].props['xlink:href']
          if element.keyframes[0].props['xlink:href'] isnt undefined
            path = element.keyframes[0].props['xlink:href'].replace /\/static\//, ''
            copyFileSync 'dist/' + path, tmp_folder + '/' + path
            # fs.createReadStream('dist/' + path).pipe(fs.createWriteStream(tmp_folder + '/' + path))

      output  = fs.createWriteStream tmp_folder + '.zip'
      archive = archiver 'zip'

      archive.on 'error', (err)->
        console.log err

      output.on 'close', ->
        console.log(archive.pointer() + ' total bytes')
        console.log('archiver has been finalized and the output file descriptor has closed.')
        res.download tmp_folder + '.zip'

      archive.pipe output
      archive.bulk([
        { expand: true, cwd: tmp_folder, src: ['**/*.*'], dest: '.'}
      ])
      archive.finalize()