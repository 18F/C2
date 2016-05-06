#= require jquery
#= require details/state/edit_mode
#= require details/state/details_request_form_state
#= require details/views/action_bar
#= require details/views/attachment_card
#= require details/data/details_save
#= require details/shell/c2
#= require details/details_helper

describe 'C2', ->

  describe '#setup', ->
    it "checks for c2", ->
      c2 = new C2() 
      expect(c2 instanceof C2).to.eql(true)
    
    it "checks for each constructor", ->
      c2 = new C2() 
      expect(c2.attachmentCardController instanceof AttachmentCardController).to.eql(true)
      expect(c2.editMode instanceof EditStateController).to.eql(true)
      expect(c2.formState instanceof DetailsRequestFormState).to.eql(true)
      expect(c2.actionBar instanceof ActionBar).to.eql(true)
      expect(c2.detailsSave instanceof DetailsSave).to.eql(true)

    it "check config passing test param actionBar", ->
      test = "action-bar-test"
      testParam = {
        actionBar: test
      }
      c2 = new C2(testParam)
      expect(c2.config.actionBar).to.eql(test)

    it "check config passing test param editMode", ->
      test = "edit-mode-test"
      testParam = {
        editMode: test
      }
      c2 = new C2(testParam)
      expect(c2.config.editMode).to.eql(test)

    it "check config passing test param attachmentCard", ->
      test = "attachment-card-test"
      testParam = {
        attachmentCard: test
      }
      c2 = new C2(testParam)
      expect(c2.config.attachmentCard).to.eql(test)

    it "check config passing test param formState", ->
      test = "form-state-test"
      testParam = {
        requestDetails: test
      }
      c2 = new C2(testParam)
      expect(c2.config.formState).to.eql(test)

    it "check config passing test param detailsSave", ->
      test = "details-save-test"
      testParam = {
        requestDetails: test
      }
      c2 = new C2(testParam)
      expect(c2.config.detailsSave).to.eql(test)

  describe '#test inits', ->
    it "event setup for action-bar-clicked:save trigger", ->
      flag = false
      testParams = setupC2TestParams()
      c2 = new C2(testParams) 
      c2.editMode.stateTo('edit')
      state = c2.editMode.getState()
      c2.actionBar.el.on "action-bar-clicked:saved", ->
        flag = true
      c2.actionBar.el.trigger("action-bar-clicked:save")
      expect(state).to.eql(true)
      expect(flag).to.eql(true)
