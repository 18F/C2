#= require jquery
#= require details/data/details_save
#= require details/details_helper

describe 'DetailsSave', ->

  describe '#setup', ->
    it "set up el", ->
      detailsSave = new DetailsSave(getRequestDetailsForm())  
      expect(detailsSave.el.length).to.eql(1)
