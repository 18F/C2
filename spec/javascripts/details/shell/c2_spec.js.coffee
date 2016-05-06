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

  describe '#test inits', ->
    it "event setup for actionBarClicked:save trigger", ->
      flag = false
      testParams = setupC2TestParams()
      c2 = new C2(testParams) 
      c2.editMode.stateTo('edit')
      state = c2.editMode.getState()
      c2.actionBar.el.on "actionBarClicked:saved", ->
        flag = true
      c2.actionBar.el.trigger("actionBarClicked:save")
      expect(state).to.eql(true)
      expect(flag).to.eql(true)
