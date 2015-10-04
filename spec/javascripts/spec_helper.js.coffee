@inputDisabledStates = ($content) ->
  states = $content.find('input').map (i, input) ->
    $(input).is(':disabled')
  states.get()
