#= require jquery
#= require details/state/edit_state_controller

describe 'EditStateController', ->
  getContent = ->
    $('
      <div class="view-mode" id="mode-parent"></div>
    ')

  describe '#state', ->
    it "on load it returns view", ->
      mode = new EditStateController(getContent())  
      expect(mode.state).to.eql('view')
  
  describe '#getState()', ->
    it "check edit state", ->
      mode = new EditStateController(getContent())  
      expect(mode.getState()).to.eql(false)

  describe '#toggleState()', ->
    it "toggle state (1) from in view mode to edit", ->
      mode = new EditStateController(getContent())  
      mode.toggleState()
      expect(mode.state).to.eql('edit')
      expect(mode.getState()).to.eql(true)

    it "toggle state multiple (4) times from in view mode to view", ->
      mode = new EditStateController(getContent())  
      mode.toggleState()
      mode.toggleState()
      mode.toggleState()
      mode.toggleState()
      expect(mode.state).to.eql('view')
      expect(mode.getState()).to.eql(false)
  
  describe '#edit-mode event', ->
    it "get the edit-mode:on", ->
      mode = new EditStateController(getContent())  
      flag = false
      
      mode.el.on 'edit-mode:on', ->
        flag = true
      
      mode.toggleState()

      expect(flag).to.eql(true)
  
    it "get the edit-mode:off", ->
      mode = new EditStateController(getContent())  
      flag = false
      
      mode.el.on 'edit-mode:off', ->
        flag = true
      
      mode.toggleState()
      mode.toggleState()

      expect(flag).to.eql(true)
