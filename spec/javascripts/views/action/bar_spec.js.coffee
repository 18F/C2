#= require jquery
#= require details/state/edit_mode
#= require details/app_details
#= require spec_helper

describe 'AppDetails', ->

  describe '#init', ->
    it "on load it returns view", ->
      detailsApp = new DetailsApp()  
      expect(mode.state).to.eql('view')
  
