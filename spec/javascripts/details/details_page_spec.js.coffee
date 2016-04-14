#= require jquery
#= require chai-jquery
#= require redesign/details

describe "detailsApp", ->
  getContent = ->
    sampleDom = ''
    $(sampleDom)

  describe "object", ->
    it "should exist", ->
      expect(detailsApp).to.be.a("object")

  describe "#blastOff()", ->
    it "should exist", ->
      expect(detailsApp.blastOff).to.be.a("function")

  describe "#setupInputFields", ->
    it "should exist", ->
      expect(detailsApp.setupInputFields).to.be.a("function")

    it "should generate data-field-guid on form", ->
      detailsApp.data.$el = getContent()
      detailsApp.setupInputFields()
      expect(detailsApp.data).to.be.a("object")

    it "should create the initial fieldUID object", ->
      detailsApp.data.$el = getContent()
      detailsApp.generateCardObjects()
      expect(detailsApp.data.fieldUID).to.be.a("object")


  describe "#generateCardObjects", ->
    it "should exist", ->
      expect(detailsApp.generateCardObjects).to.be.a("function")

    it "should create the initial data object", ->
      detailsApp.data.$el = getContent()
      detailsApp.generateCardObjects()
      expect(detailsApp.data).to.be.a("object")

    it "should create the initial fieldUID object", ->
      detailsApp.data.$el = getContent()
      detailsApp.generateCardObjects()
      expect(detailsApp.data.fieldUID).to.be.a("object")
