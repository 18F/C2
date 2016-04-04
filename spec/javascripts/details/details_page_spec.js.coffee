#= require jquery
#= require redesign_details

describe "detailsApp", ->
  getContent = ->
    $('
      <div data-card-requestDetails="">
        <input data-card-key="requestDetails-expenseType" data-card-value="BA60" />
        <input data-card-key="requestDetails-directPay" data-card-value="false" />
        <input data-card-key="requestDetails-orgCode" data-card-value="4" />
        <input data-card-key="requestDetails-functionCode" data-card-value="" />
        <input data-card-key="requestDetails-listItem-item" data-card-value="gah" />
        <input data-card-key="purchaseDetails-hasAttachment" data-card-value="false" />
      </div>
    ')

  describe "object", ->
    it "should exist", ->
      expect(detailsApp).to.be.a("object")

  describe "#blastOff()", ->
    it "should exist", ->
      expect(detailsApp.blastOff).to.be.a("function")

  describe "#setupDataObject", ->
    it "should exist", ->
      expect(detailsApp.setupDataObject).to.be.a("function")

    it "should create the initial data object", ->
      detailsApp.setupDataObject( getContent() )

      expect(detailsApp.data).to.be.a("object")

    it "should nest objects based on data attribute name", ->
      detailsApp.setupDataObject( getContent() )

      expect(detailsApp.data.requestDetails).to.be.a("object")
      expect(detailsApp.data.requestDetails.expenseType).to.be.a("string")

    it "should fill object values one level deep correctly", ->
      detailsApp.setupDataObject( getContent() )

      expect(detailsApp.data.requestDetails.expenseType).to.equal("BA60")
      expect(detailsApp.data.requestDetails.directPay).to.equal(false)
      expect(detailsApp.data.requestDetails.orgCode).to.equal(4)
      expect(detailsApp.data.requestDetails.functionCode).to.equal("")
      expect(detailsApp.data.purchaseDetails.hasAttachment).to.equal(false)

    it "should fill object values two levels deep correctly", ->
      detailsApp.setupDataObject( getContent() )
      expect(detailsApp.data.requestDetails.listItem.item).to.equal("gah")

  describe "#updateStaticElements", ->
    it "updates the text of static elements with data-card attributes", ->

      staticContent = $('
          <div>
            <span id="el1" data-card-key="requestDetails-expenseType"
              data-card-value="frog">frog</span>
            <div id="el2" data-card-key="purchaseDetails-hasAttachment"
              data-card-value="frog">fred</div>
          </div>
        ')

      detailsApp.setupDataObject( getContent() )
      detailsApp.updateStaticElements(staticContent)

      expect(staticContent.find("#el1").text()).to.equal("BA60")
      expect(staticContent.find("#el2").text()).to.equal("false")
      expect(staticContent.find("#el1").data("card-value")).to.equal("BA60")
      expect(staticContent.find("#el2").data("card-value")).to.equal(false)

  describe "#lookup", ->
    it "looks up values in the details data with a hyphenated string key", ->
      detailsApp.setupDataObject( getContent() )

      expect(detailsApp.lookup("requestDetails-orgCode")).to.equal(4)
