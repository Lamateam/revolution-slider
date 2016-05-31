define "libs/api", ->
  console.log "!!!", $
  JCapi_used_routes = {}
  JCapi = (url, method='GET', data={}, force=false)->
    callbacks = {}
    if JCapi_used_routes[url] is undefined
      JCapi_used_routes[url] = true
      $.ajax
        url: url
        method: method
        contentType: "application/json"
        data: if method is "GET" then data else JSON.stringify data
        success: (data)->
          JCapi_used_routes[url] = undefined
          if data['!err'] isnt undefined
            callbacks['fail'](data) if typeof callbacks['fail'] is 'function'
          else
            callbacks['success'](data) if typeof callbacks['success'] is 'function'
        fail: (xhr)->
          JCapi_used_routes[url] = undefined
          callbacks['fail'](xhr) if typeof callbacks['fail'] is 'function'
        error: (xhr)->
          JCapi_used_routes[url] = undefined
          callbacks['fail'](xhr) if typeof callbacks['fail'] is 'function'
    else
      sweetAlert window.language.global.error, window.language.global.popup.busy, "error"
    return (success)->
      callbacks['success'] = success
      return (fail)->
        callbacks['fail'] = fail