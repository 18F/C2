#= require jquery
#= require details/state/edit_mode
#= require details/state/details_request_form_state
#= require details/views/action_bar
#= require details/views/attachment_card
#= require details/shell/c2
#= require details/details_helper

describe 'C2', ->

  describe '#setup', ->
    it "checks for each constructor", ->
      c2 = new C2() 
      expect(c2.attachmentCardController instanceof AttachmentCardController).to.eql(true)
      expect(c2.editMode instanceof EditStateController).to.eql(true)
      expect(c2.formState instanceof DetailsRequestFormState).to.eql(true)
      expect(c2.actionBar instanceof ActionBar).to.eql(true)

    it "check config passing test param actionBar", ->
      test = "action-bar-test"
      testParam = {
        actionBar: test
      }
      c2 = new C2(testParam)
      expect(c2.config.actionBar).to.eql(test)
