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
  
