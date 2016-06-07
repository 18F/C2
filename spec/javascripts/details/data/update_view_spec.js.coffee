#= require jquery
#= require details/data/update_view
#= require details/details_helper

describe 'UpdateView', ->

  describe '#setup', ->
    it "set up el", ->
      updateView = new UpdateView(getUpdateViewContent())  
      expect(updateView.el.length).to.eql(1)

  describe '#updateTextFields', ->
    it "check that form fields values can be updated", ->
  
  describe '#updateCheckbox', ->
    it "make the checkbox checked", ->
    it "make the checkbox unchecked", ->
