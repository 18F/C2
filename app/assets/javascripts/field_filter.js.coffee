class @FieldFilter
  constructor: (@$fieldOrWrappers) ->

  toggle: (showOrHide) ->
    # https://www.paciellogroup.com/blog/2012/05/html5-accessibility-chops-hidden-and-aria-hidden/
    @$fieldOrWrappers.attr('aria-hidden', !showOrHide)

    # disable inputs so they aren't submitted with the form
    if @$fieldOrWrappers.is(':input')
      @$fieldOrWrappers.attr('disabled', !showOrHide)
    @$fieldOrWrappers.find(':input').attr('disabled', !showOrHide)

  show: ->
    @toggle(true)

  hide: ->
    @toggle(false)
