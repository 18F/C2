#= require jquery
#= require action_bar

describe 'ActionBar', ->
  getContent = ->
    $(
      '<div class="action-bar-template action-bar-wrapper">
        <ul id="request-actions">
          <li class="cancel-button">
            <input type="button" value="Cancel">
          </li>
          <li class="save-button">
            <input type="button" value="Save">
          </li>
        </ul>
      </div>'
    )

  describe '#setup', ->
    it "set in view mode", ->
      actionBar = new ActionBar(getContent())  
      expect(actionBar.el.hasClass('edit-actions')).to.eql(false)
    
    it "anchor link is not disabled", ->
      actionBar = new ActionBar(getContent())  
      expect(actionBar.el.find('.save-button input').is(":disabled")).to.eql(true)
  
  describe '#_events .save-button', ->

    it "save fires event when enabled", ->
      flag = false
      actionBar = new ActionBar(getContent())
      actionBar.editMode()
      actionBar.el.find(".save-button input").prop('disabled', false)
      actionBar.el.on "actionBarClicked:save", ->
        flag = true
      actionBar.el.find(".save-button input").trigger('click')
      expect(flag).to.eql(true)

    it "save doesnt fire event when disabled", ->
      spy = false
      actionBar = new ActionBar(getContent())
      actionBar.el.on "actionBarClicked:save", ->
        spy = true
      actionBar.el.find(".save-button input").trigger('click')
      expect(spy).to.eql(false)
  
  describe '#_events .cancel-button', ->

    it "cancel fires event when enabled", ->
      spy = false
      actionBar = new ActionBar(getContent())
      actionBar.el.on "actionBarClicked:cancel", ->
        spy = true
      actionBar.el.find(".cancel-button input").trigger('click')
      expect(spy).to.eql(true)

    it "cancel doesnt fire event when disabled", ->
      spy = false
      actionBar = new ActionBar(getContent())
      actionBar.el.on "actionBarClicked:cancel", ->
        spy = true
      actionBar.el.find(".cancel-button input").trigger('click')
      expect(spy).to.eql(false)

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
