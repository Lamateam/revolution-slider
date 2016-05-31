express      = require 'express'
session      = require 'express-session'
YAML         = require 'yamljs'
body_parser  = require 'body-parser'
jade_amd     = require "jade-amd"

config       = require "./config.json"

app = express()

# jade config
app.set "views", "src/views"
app.set 'view engine', 'jade'

# session
app.use session config.session

# static
app.use "/static", express.static("dist")
app.use "/static/html", jade_amd.jadeAmdMiddleware({})

# set locale pack
language_packages = {}
for lang in config.languages 
  language_packages[lang] = YAML.load "src/language/" + lang + "/main.yml"

app.use (req, res, next)->
  res.locals.config = config.jade
  req.session.lang = "russian" if req.session.lang is undefined

  lang = req.session.lang
  res.locals.language = language_packages[lang]
  res.locals.language_string = JSON.stringify(language_packages[lang])

  next()

# bodyparser for json
app.use body_parser.json({ type: 'application/json' })

# routes
require("./routes/main.coffee").init app

app.listen config.port, ()->
  console.log 'App listening on port 3000!'
