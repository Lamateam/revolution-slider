define "libs/helpers", ->
  res = 
    invertRGB: ->
      rgb = Array.prototype.join.call(arguments).match(/(-?[0-9\.]+)/g)
      res = [ 255 - rgb[0], 255 - rgb[1], 255 - rgb[2] ]
      res.push(1 - rgb[3]) if rgb.length is 4
      res