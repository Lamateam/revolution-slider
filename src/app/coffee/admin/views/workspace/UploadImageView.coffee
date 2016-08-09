define "views/workspace/UploadImageView", [ 
  "marionette"
  'collections/ImagesCollection'
  "templates/workspace/upload_image"
  "jquery.iframe-transport"
  "jquery.fileupload"
], (Marionette, ImagesCollection, UploadImageTemplate)->
  Marionette.ItemView.extend
    className: 'load'
    ui:
      image_url: '.bind-image-url'
      image_input: '.bind-image-input'
      image_button: '.bind-image-button'
    events:
      'blur .bind-image-url': 'onImageUrlBlur'
      'click .bind-gallery': 'switchGallery'
      'click .bind-upload': 'switchUpload'
      'click .event-close-btn': 'destroy'
      'click .event-select-img': 'selectImage'
    template: UploadImageTemplate
    templateHelpers: ->
      opt = @options
      res = 
        state: -> opt.state
        images: -> opt.images
    initialize: (@options={})->
      @options.state = 'upload'
      @options.images = [  ]
      collection = new ImagesCollection()
      collection.fetch { 
        success: => 
          console.log collection.toJSON()
          @options.images = collection.toJSON() 
          @render()
      }
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
              fill: "ffffff"
              "xlink:href": data.result.url
              'fill-opacity': 1
          }
        ]
      }
    onImageUrlBlur: ->
      window.App.trigger "image:url_upload", { url: @ui.image_url.val() }
    switchUpload: (e)->
      @options.state = 'upload'
      @render()
    switchGallery: (e)->
      @options.state = 'gallery'
      @render()
    selectImage: (e)->
      @createElement { result: { url: e.target.src } }
      @destroy()
