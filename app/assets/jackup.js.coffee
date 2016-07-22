$ -> # when the document is ready
  # create a new processor with the endpoint to where your assets are uploaded
  jackUp = new JackUp.Processor(path: '/assets')

  # called if upload is an image; returns an image jQuery object with src attribute assigned
  jackUp.on 'upload:imageRenderReady', (e, options) ->
    # assigns a data-attribute with the file guid for later referencing
    # set the border color to red, denoting that the image is still being uploaded
    options.image.attr("data-id", options.file.__guid__).css(border: "5px solid red")
    $('.file-drop').append(options.image)

  # upload has been sent to server; server will handle processing
  jackUp.on "upload:sentToServer", (e, options) ->
    # change the border color to yellow to signify successful upload (server is still processing)
    $("img[data-id='#{options.file.__guid__}']").css borderColor: 'yellow'

  # when server responds successfully
  jackUp.on "upload:success", (e, options) ->
    # server has completed processing the image and has returned a response
    $("img[data-id='#{options.file.__guid__}']").css(borderColor: "green")

  # when server returns a non-200 response
  jackUp.on "upload:failure", (e, options) ->
    # alert the file name
    alert("'#{options.file.name}' upload failed; please retry")
    # remove the image from the dom since the upload failed
    $("img[data-id='#{options.file.__guid__}']").remove()

  window.jackUp = jackUp
 $('.card-for-attachments').jackUpDragAndDrop(jackUp)

  # if you do not want the browser to redirect to the file when droped anywhere else on the page
  $(document).bind 'drop dragover', (e) ->
    e.preventDefault()
