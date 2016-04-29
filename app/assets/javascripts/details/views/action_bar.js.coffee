class ActionBar
  constructor: (el) ->
    @el = $(el)
    @_setup()
    this

  _setup: ->
    @viewMode()
    return

  viewMode: ->
    @el.removeClass('edit-actions')
    @el.find('.save-button input').attr("disabled", "disabled")
    return

  editMode: ->
    @el.addClass('edit-actions')
    @el.find('.save-button input').attr("disabled", false)
    return
