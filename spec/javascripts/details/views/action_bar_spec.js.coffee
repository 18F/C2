#= require jquery
#= require action_bar

describe 'ActionBar', ->
  getContent = ->
    $(
      '<div class="action-bar-template action-bar-wrapper">
        <div class="cancel-button">
          <input disabled="disabled" type="button" value="Cancel">
        </div>
        <div class="save-button">
          <input disabled="disabled" type="button" value="Save">
        </div>
      </div>'
    )

  describe '#setup', ->
    it "set in view mode", ->
      actionBar = new ActionBar(getContent())  
      expect(actionBar.el.hasClass('edit-actions')).to.eql(false)
    
    it "anchor link is not disabled", ->
      actionBar = new ActionBar(getContent())  
      expect(actionBar.el.find('.save-button input').is(":disabled")).to.eql(true)
  
  describe '#_events', ->
    it "save fires event when enabled", ->
      spy = false
      actionBar = new ActionBar(getContent())
      actionBar.editMode()
      actionBar.el.on "actionBar:saveClicked", ->
        spy = true
      actionBar.el.find(".save-button input").click()
      expect(spy).to.eql(true)

    it "cancel fires event when enabled", ->
      spy = false
      actionBar = new ActionBar(getContent())
      actionBar.editMode()
      actionBar.el.on "actionBar:cancelClicked", ->
        spy = true
      actionBar.el.find(".cancel-button input").click()
      expect(spy).to.eql(true)

  describe '#editMode', ->
    it "set edit mode", ->
      actionBar = new ActionBar(getContent())  
      actionBar.editMode()
      expect(actionBar.el.hasClass('edit-actions')).to.eql(true)
    
    it "save button is not disabled", ->
      actionBar = new ActionBar(getContent())  
      actionBar.editMode()
      expect(actionBar.el.find('.save-button input').is(":disabled")).to.eql(false)
  
  describe '#viewMode', ->
    it "set edit mode and revert to view mode", ->
      actionBar = new ActionBar(getContent())  
      actionBar.editMode()
      actionBar.viewMode()
      expect(actionBar.el.hasClass('edit-actions')).to.eql(false)

    it "save button is disabled", ->
      actionBar = new ActionBar(getContent())  
      actionBar.editMode()
      actionBar.viewMode()
      expect(actionBar.el.find('.save-button input').is(":disabled")).to.eql(true)
