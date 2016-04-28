#= require jquery
#= require details/state/edit-mode

describe 'EditMode', ->
  getContent = ->
    $('<div class="view-mode" id="mode-parent"></div>')
  describe 'events', ->
    it "sets up", ->
      mode = new EditStateController(getContent())
      expect(mode.state).to.eql('view')



