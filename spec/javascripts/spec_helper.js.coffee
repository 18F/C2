@inputDisabledStates = ($content) ->
  states = $content.find('input').map (i, input) ->
    $(input).is(':disabled')
  states.get()

@triggerKeyDown = (element, keyCode) ->
  press = jQuery.Event("keyup");
  press.ctrlKey = false;
  press.which = keyCode;
  element.trigger(press);
