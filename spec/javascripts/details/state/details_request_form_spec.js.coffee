#= require jquery
#= require details/state/details_request_form_state
#= require spec_helper

describe 'DetailsRequestFormState', ->
  getContent = ->
    $('
      <div id="request-details-card">
        <form>
          <label>
            <input id="field_1">
          </label>
          <label>
            <input id="field_2">
          </label>
        </form>
      </div>
    ')
