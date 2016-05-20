#= require jquery
#= require ladda/ladda.min
#= require ladda/ladda.jquery.min
#= require details/views/action_bar
#= require details/details_helper
#= require ladda/spin.min

describe 'ActionBar', ->

  describe '#setup', ->
    it "set in view mode", ->
      actionBar = new ActionBar(getActionBarContent())  
      expect(actionBar.el.hasClass('edit-actions')).to.eql(false)
    
    it "anchor link is not disabled", ->
  
  describe '#_events .save-button', ->
    it "flag is set", ->
      flag = false
      actionBar = new ActionBar(getActionBarContent())
      actionBar.setMode('edit')
      expect(flag).to.eql(false)

    it "save fires event when enabled", ->
      flag = false
      actionBar = new ActionBar(getActionBarContent())
      actionBar.setMode('edit')
      actionBar.el.on "action-bar-clicked:save", ->
        flag = true
      actionBar.el.trigger('action-bar-clicked:save')
      expect(flag).to.eql(true)
  
  describe '#_events .cancel-button', ->
    it "cancel fires event when enabled", ->
      flag = false
      actionBar = new ActionBar(getActionBarContent())
      actionBar.el.on "action-bar-clicked:cancel", ->
        flag = true

      actionBar.el.trigger('action-bar-clicked:cancel')
      expect(flag).to.eql(true)

  describe '#editMode', ->
    it "set edit mode", ->
    
    it "save button is not disabled", ->
      
  describe '#viewMode', ->
    it "set edit mode and revert to view mode", ->
      
    it "save button is disabled", ->
      
