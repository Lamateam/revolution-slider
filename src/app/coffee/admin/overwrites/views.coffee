define "overwrites/views", [ "marionette" ], (Marionette)->
  Marionette.ItemView = Marionette.ItemView.extend
    error: (msg="error")->
      swal "Ошибка...", msg, "error"