#= require jquery
#= require details/state/edit_mode
#= require details/state/details_request_form_state
#= require details/views/action_bar
#= require details/views/attachment_card
#= require details/shell/c2

describe 'C2', ->
  getEditModeContent = ->
    $('
      <div class="view-mode" id="mode-parent"></div>
    ')

  describe '#setup', ->
    it "checks for each constructor", ->
      c2 = new C2() 
      expect(c2.attachmentCardController instanceof AttachmentCardController).to.eql(true)
      expect(c2.editMode instanceof EditStateController).to.eql(true)
      expect(c2.formState instanceof DetailsRequestFormState).to.eql(true)
      expect(c2.actionBar instanceof ActionBar).to.eql(true)

  describe '_actionBarSave()', ->
    it "event setup for actionBarClicked:save trigger", ->
      window = {}
      window.test = {
        editMode: getEditModeContent()
      }
      flag = false
      c2 = new C2() 
      state = c2.editMode.getState()
      c2.editMode.toggleState()
      c2.actionBar.el.on "actionBarClicked:saved", ->
        flag = true
      c2.actionBar.el.trigger("actionBarClicked:save")
      expect(state).to.eql(true)
      expect(state).to.eql(true)
      # expect(flag).to.eql(true)
