#= require jquery
#= require details/views/details_request_card
#= require moment
#= require spec_helper
#= require details/details_helper

describe 'DetailsRequestCard', ->
  
  describe '#_event', ->
    it "form keypress is triggered on input field", ->
