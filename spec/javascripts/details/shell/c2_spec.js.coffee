#= require jquery
#= require details/state/edit_mode
#= require details/views/action_bar
#= require details/views/attachment_card
#= require details/shell/c2

describe 'C2', ->
  describe '#setup', ->
    it "checks for each constructor", ->
      c2 = new C2() 
      expect(c2.attachmentCardController instanceof AttachmentCardController).to.eql(true)
      expect(c2.editMode instanceof EditStateController).to.eql(true)
      expect(c2.actionBar instanceof ActionBar).to.eql(true)
