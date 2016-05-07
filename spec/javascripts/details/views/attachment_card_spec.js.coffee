#= require jquery
#= require details/views/attachment_card
#= require details/details_helper

describe 'Attachment Card', ->

  describe '#initialize', ->
    it "on load it returns controller with options", ->
      controller = new AttachmentCardController(getAttachmentContent())  
      expect(controller.label_class).to.eql('attachment-label')
      expect(controller.list_item_class).to.eql('attachment-list-item')
      expect(controller.loading_class).to.eql('attachment-loading')
      expect(controller.file_class).to.eql('attachment-loading-file')
      expect(controller.gif_class).to.eql('attachment-loading-gif')
      expect(controller.list_class).to.eql('attachment-list')
      expect(controller.gif_src).to.eql('/assets/spin.gif')
      expect(controller.form_id).to.eql('#new_attachment')

  describe '#disableLabel()', ->
    it "disables the label of the file input", ->
      content = getAttachmentContent();
      controller = new AttachmentCardController(content)
      controller.disableLabel();
      expect(content.find('label').hasClass('disabled'))

  describe '#getListItem()', ->
    it "returns a attachment list item", ->
      controller = new AttachmentCardController(getAttachmentContent())
      expect(controller.getListItem().html())
       .to
        .eql('<img class="attachment-loading-gif" src="/assets/spin.gif" alt="loading"><strong class="attachment-loading"></strong>')

  describe '#appendLoadingFile()', ->
    it "appends loading file to an empty list", ->
      content = getAttachmentContent()
      controller = new AttachmentCardController(content)
      controller.appendLoadingFile();
      expect(content.find('.attachment-list').html()).to.eql('<li class="attachment-list-item attachment-loading"><img class="attachment-loading-gif" src="/assets/spin.gif" alt="loading"><strong class="attachment-loading"></strong></li>')
    it "appends a second file after the first", ->
      content = getAttachmentContent()
      controller = new AttachmentCardController(content)
      controller.appendLoadingFile();
      controller.appendLoadingFile();
      expect(content.find('.attachment-list-item').length)
      .to.eql(2);
