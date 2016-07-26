define "views/workspace/UploadImageView", [ 
  "marionette"
  "templates/workspace/upload_image"
  "jquery.iframe-transport"
  "jquery.fileupload"
], (Marionette, UploadImageTemplate)->
  Marionette.ItemView.extend
    className: 'load'
    ui:
      image_url: '.bind-image-url'
      image_input: '.bind-image-input'
      image_button: '.bind-image-button'
    events:
      'blur .bind-image-url': 'onImageUrlBlur'
      'click .event-close-btn': 'destroy'
    template: UploadImageTemplate
    onRender: ->
      $(@ui.image_input).fileupload 
        dataType: 'json'
        done: (e, data)=>
          @createElement data
          @destroy()
    createElement: (data)->
      window.App.trigger "element:create", { 
        type: "image"
        keyframes: [
          {
            start: 0
            props: 
              x: 100
              y: 100
              angle: 0
              width: 170
              height: 200
              fill: "rgb(0,0,0)"
              "xlink:href": data.result.url
          }
        ]
      }
    onImageUrlBlur: ->
      window.App.trigger "image:url_upload", { url: @ui.image_url.val() }