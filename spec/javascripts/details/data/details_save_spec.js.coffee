#= require jquery
#= require details/data/details_save
#= require details/details_helper

describe 'DetailsSave', ->

  describe '#setup', ->
    it "set up el", ->
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())  
      expect(detailsSave.el.length).to.eql(1)

  describe '#event details-form:save', ->
    it "exists", ->
      eventName = 'details-form:save'
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      events = $._data(detailsSave.el[0], "events")
      expect(events[eventName]).to.not.eql(undefined)
    
    it "passes data", ->
      eventName = 'details-form:save'
      flagged = 0
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      detailsSave.el.on(eventName, (event, data) ->
          flagged = data['test']
        )
      detailsSave.el.trigger(eventName, {test: 1})
      expect(flagged).to.eql(1)
      
  describe '#event details-form:respond', ->
    eventName = 'details-form:respond'
    it "exists", ->
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      events = $._data(detailsSave.el[0], "events")
      expect(events[eventName]).to.not.eql(undefined)
    it "passes data", ->
      flagged = 0
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      detailsSave.el.on(eventName, (event, data) ->
          flagged = data['test']
        )
      detailsSave.el.trigger(eventName, {test: 1})
      expect(flagged).to.eql(1)

  describe '#event details-form:error', ->
    eventName = 'details-form:error'
    it "exists", ->
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      events = $._data(detailsSave.el[0], "events")
      expect(events[eventName]).to.not.eql(undefined)
    it "passes data", ->
      flagged = 0
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      detailsSave.el.on(eventName, (event, data) ->
          flagged = data['test']
        )
      detailsSave.el.trigger(eventName, {test: 1})
      expect(flagged).to.eql(1)

  describe '#event details-form:success', ->
    eventName = 'details-form:success'
    it "exists", ->
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      events = $._data(detailsSave.el[0], "events")
      expect(events[eventName]).to.not.eql(undefined)
    it "passes data", ->
      flagged = 0
      detailsSave = new DetailsSave(getRequestDetailsForm(), getRequestDetailsForm())
      detailsSave.el.on(eventName, (event, data) ->
          flagged = data['test']
        )
      detailsSave.el.trigger(eventName, {test: 1})
      expect(flagged).to.eql(1)

  describe '#saveDetailsForm', ->
    it "form is submitted by event", ->

  describe '#receiveResponse', ->
    it "success case", ->
    it "error case", ->
