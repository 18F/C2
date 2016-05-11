#= require jquery
#= require selectize
#= require selectizer
#= require hidden_until_select
#= require details/views/observer_card
#= require details/details_helper


describe 'Observer Card', ->

  describe '#initialize', ->
    it "on load it returns controller with options", ->
      controller = new ObserverCardController(getObserverContent(),{some_option:"is there"})
      expect(controller.some_option).to.eql('is there')

  