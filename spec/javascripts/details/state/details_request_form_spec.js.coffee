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
  
  describe '#_event', ->
    it "form keypress is triggered on input field", ->
      test_ran = false
      content = getContent()
      form = new DetailsRequestFormState(content)  
      form._setup()
      first_field = content.find('input').first()
      form.el.on 'form:changed', ( ->
        test_ran = true
      )
      triggerKeyDown(first_field, 70)
      expect(test_ran).to.eql(true)
