#= require jquery
#= require details/state/details_request_form_state
#= require spec_helper
#= require details/details_helper

describe 'DetailsRequestFormState', ->

  describe '#_createGuid', ->
    it "create the uid on form and input", ->
      content = getRequestDetailsForm()
      form = new DetailsRequestFormState(content)  
      form._setup()
      guidFields = content.find('[data-field-guid]')
      expect(guidFields.length).to.eql(4)
      expect(guidFields.length).not.eql(2)
  
  describe '#_event', ->
    it "form keypress is triggered on input field", ->
      test_ran = false
      content = getRequestDetailsForm()
      form = new DetailsRequestFormState(content)  
      form._setup()
      first_field = content.find('input').first()
      form.el.on 'form:changed', ( ->
        test_ran = true
      )
      triggerKeyDown(first_field, 70)
      expect(test_ran).to.eql(true)
