fs   = require 'fs'
path = require 'path'

exports.init = (app)->
  app.get '/api/images/list', (req, response, next)->
    fs.readdir 'dist/uploaded_images', (err, files)->
      data = [  ]
      console.log err
      for file in files
        data.push { url: '/static/uploaded_images/' + file }

      response.send data