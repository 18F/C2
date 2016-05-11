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
      actionBar = new ActionBar(getActionBarContent())  
      expect(actionBar.el.find('.save-button button').is(":disabled")).to.eql(true)
  
  describe '#_events .save-button', ->
    it "flag is set", ->
      flag = false
      actionBar = new ActionBar(getActionBarContent())
      actionBar.editMode()
      expect(flag).to.eql(false)

    it "save fires event when enabled", ->
      flag = false
      actionBar = new ActionBar(getActionBarContent())
      actionBar.editMode()
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
      actionBar = new ActionBar(getActionBarContent())  
      actionBar.editMode()
      expect(actionBar.el.hasClass('edit-actions')).to.eql(true)
    
    it "save button is not disabled", ->
      actionBar = new ActionBar(getActionBarContent())  
      actionBar.editMode()
      expect(actionBar.el.find('.save-button button').is(":disabled")).to.eql(false)
  
  describe '#viewMode', ->
    it "set edit mode and revert to view mode", ->
      actionBar = new ActionBar(getActionBarContent())  
      actionBar.editMode()
      actionBar.viewMode()
      expect(actionBar.el.hasClass('edit-actions')).to.eql(false)

    it "save button is disabled", ->
      actionBar = new ActionBar(getActionBarContent())  
      actionBar.editMode()
      actionBar.viewMode()
      expect(actionBar.el.find('.save-button button').is(":disabled")).to.eql(true)
