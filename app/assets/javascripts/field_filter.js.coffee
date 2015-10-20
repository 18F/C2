class @FieldFilter
  constructor: (@$fieldOrWrappers) ->

  isInput: ->
    @$fieldOrWrappers.is(':input')

  toggleVisibility: (showOrHide) ->
    # https://www.paciellogroup.com/blog/2012/05/html5-accessibility-chops-hidden-and-aria-hidden/
    @$fieldOrWrappers.attr('aria-hidden', !showOrHide)

  toggleEnabled: (enableOrDisable) ->
    @$fieldOrWrappers.attr('disabled', !enableOrDisable)

  toggleChildInputs: (enableOrDisable) ->
    @$fieldOrWrappers.find(':input').attr('disabled', !enableOrDisable)

  toggle: (showOrHide) ->
    @toggleVisibility(showOrHide)

    # hidden inputs need to be disabled, so they aren't submitted with the form
    if @isInput()
      @toggleEnabled(showOrHide)
    else
      @toggleChildInputs(showOrHide)

  show: ->
    @toggle(true)

  hide: ->
    @toggle(false)
