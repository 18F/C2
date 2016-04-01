#= require jquery
#= require redesign_details



describe "detailsApp", ->
  getContent = ->
    $("
      <div data-card-requestDetails="">
        <input data-card-requestDetails-expenseType="BA60" />
        <input data-card-requestDetails-directPay="false" />
        <input data-card-requestDetails-orgCode="p04" />
        <input data-card-requestDetails-functionCode="" />
      </div>
    ")

  describe "object", ->
    it "should exist", ->
      expect(detailsApp).to.be.a("object")

  describe "#blastOff()", ->
    it "should exist", ->
      expect(detailsApp.blastOff()).to.be.a("function")

  describe "#setupDataObject", ->
    it "should create the initial data object", ->
      detailsApp.setupDataObject( getContent() )
      
      expect(detailsApp.data).to.be.a("object")

    it "should nest objects based on data attribute name", ->
      detailsApp.setupDataObject( getContent() )
      
      expect(detailsApp.data.requestDetails).to.be.a("object")
      expect(detailsApp.data.requestDetails.expenseType).to.be.a("string")
    
    it "should fill object values correctly", ->
      detailsApp.setupDataObject( getContent() )
      
      expect(detailsApp.data.requestDetails.expenseType).to.equal("BA60")
      expect(detailsApp.data.requestDetails.directPay).to.equal("false")
      expect(detailsApp.data.requestDetails.orgCode).to.equal("p04")
      expect(detailsApp.data.requestDetails.functionCode).to.equal("")
