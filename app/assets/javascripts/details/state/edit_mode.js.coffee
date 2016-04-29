class EditStateController
  constructor: (el) ->
    @el = $(el)
    @_setup()
    this
  
  _setup: ->
    @state = "view"
    @_event()
    return

  _event: ->
    @el.on "edit-mode:toggle", (event) ->
      mode = $(this)
      if mode.is ".edit-mode" 
        @state = "edit"
        @el.trigger "edit-mode:on"
      else
        this.state = "view";
        this.el.trigger "edit-mode:off"

  getState: ->
    if @el.hasClass "edit-mode"
      true
    else
      false

  toggleState: ->
    if @el.is ".edit-mode"
      @stateTo 'view'
    else if @el.is ".view-mode"
      @stateTo 'edit'
    
  stateTo: (state) ->
    @state = state
    newState = state + '-mode'
    @el.addClass newState

    switch state
      when "view"
        @el.removeClass 'edit-mode'
        @el.trigger 'edit-mode:off'
      when "edit"
        @el.removeClass 'view-mode'
        @el.trigger 'edit-mode:on'
 
