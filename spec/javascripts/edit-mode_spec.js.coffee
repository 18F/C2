#= require jquery
#= require details/state/edit-mode
#= require spec_helper

describe 'EditMode', ->
  getContent = ->
    $('
      <div class="view-mode" id="mode-parent"></div>
    ')
  
  describe '.state', ->
    it "on load it returns view", ->
      mode = new EditStateController(getContent())
  
      expect(mode.state).to.eql('view')



