define "views/workspace/UploadEditImageView", [ 
  "views/workspace/UploadImageView"
], (UploadImageView)->
  UploadImageView.extend
    createElement: (data)->
      window.App.trigger "element:" + @options.id + ":change", { props: { "xlink:href": data.result.url } }
    onImageUrlBlur: ->
      window.App.trigger "image:url_upload", { url: @ui.image_url.val(), id: @options.id }