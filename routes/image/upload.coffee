fs      = require 'fs'
request = require 'request'
Busboy  = require 'busboy'

exports.init = (app)->
  app.post '/api/images/upload/url', (req, response, next)->
    request.head req.body.url, (err, res, body)->
      if err
        console.log err
        response.sendStatus 500
      else
        arr    = req.body.url.split '.'
        ext    = arr[arr.length - 1]
        fname  = Date.now() + '.' + ext
        request(req.body.url).pipe(fs.createWriteStream('dist/uploaded_images/' + fname)).on 'close', ->
          response.send { url: '/static/uploaded_images/' + fname }

  app.post '/api/images/upload/file', (req, res, next)->
    busboy = new Busboy { headers: req.headers }

    busboy.on "file", (fieldname, file, filename, encoding, mimetype)->
      console.log 'File [' + fieldname + ']: filename: ' + filename + ', encoding: ' + encoding + ', mimetype: ' + mimetype

      arr = filename.split '.'
      extension = arr[arr.length-1]
      file_name = 'uploaded_images/image-' + Date.now() + "." + extension

      stream = file.pipe fs.createWriteStream("./dist/" + file_name)
      stream.on 'finish', ->
        res.send { url: '/static/' + file_name }

    req.pipe busboy