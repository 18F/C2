#= require jquery
#= require details/data/details_save
#= require details/details_helper

describe 'DetailsSave', ->

  describe '#setup', ->
    it "set up el", ->
      detailsSave = new DetailsSave(getRequestDetailsForm())  
      expect(detailsSave.el.length).to.eql(1)

  describe '#saveDetailsForm', ->
    it "form is submitted by event", ->
      flag = false
      detailsSave = new DetailsSave(getRequestDetailsForm())  
      detailsSave.el.find('form').on 'submit', ->
        flag = true
      detailsSave.el.trigger('details-form:save')
      expect(flag).to.eql(true)

  describe '#saveDetailsForm', ->
    it "form is submitted by function", ->
      flag = false
      detailsSave = new DetailsSave(getRequestDetailsForm())  
      detailsSave.el.find('form').on 'submit', ->
        flag = true
      detailsSave.saveDetailsForm()
      expect(flag).to.eql(true)
