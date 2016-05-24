#= require jquery
#= require selectize
#= require selectizer
#= require required_for_submit
#= require details/views/modal_card
#= require details/details_helper


describe 'Modal Generator', ->

  describe '#initialize', ->
    it "on load it returns controller with options", ->
      controller = new ModalController(getModalCardContent())
      expect(controller instanceof ModalController).to.eql(true)

  describe '#create', ->
    it "modal-wrapper will be visible to create a black background", ->

  describe 'close button works', ->
    it "click the cancel button", ->
    it "click the close X in the corner", ->

  describe 'Setup data based on modals', ->
    it "increment the data.id on creation", ->
  
  describe 'increment id when new modal is created', ->
