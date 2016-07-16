define "views/workspace/UploadEditImageView", [ 
  "views/workspace/UploadImageView"
], (UploadImageView)->
  UploadImageView.extend
    createElement: (data)->
      window.App.trigger "element:change", { el: @options.id, props: { "xlink:href": data.result.url } }
    onImageUrlBlur: ->
      window.App.trigger "image:url_upload", { url: @ui.image_url.val(), id: @options.id }