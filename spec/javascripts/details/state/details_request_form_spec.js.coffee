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

  describe '#_createGuid', ->
    it "create the uid on form and input", ->
      content = getContent()
      form = new DetailsRequestFormState(content)  
      form._setup()
      guidFields = content.find('[data-field-guid]')
      expect(guidFields.length).to.eql(3)
      expect(guidFields.length).not.eql(2)
