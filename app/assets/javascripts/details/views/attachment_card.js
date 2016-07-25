var AttachmentCardController;

AttachmentCardController = (function(){

  function AttachmentCardController(el, opts){
    this.el = typeof el === "string" ? $(el) : el;
    this._setup(opts);
    return this;
  }

  AttachmentCardController.prototype._setup = function(opts){
    opts = opts || {};
    this.default_config = this._getDefaultConfig();
    this._setDefaults(opts);
    this._event();
  }

  AttachmentCardController.prototype.update = function(html, fileName){
    this.el.html(html);
    this.el.trigger('attachment-card:updated', fileName);
  }

  AttachmentCardController.prototype._getDefaultConfig = function(){
    var proposalId = $("#proposal_id").attr("data-proposal-id");
    return $.extend({
      form_id: "#new_attachment",
      gif_src: "/assets/spin.gif",
      attachmentUrl: "/proposals/" + proposalId + "/attachments",
      buttonSelector: "[for'attachment_file']",
      contentSelector: "input[type='file']"
    }, this._getDefaultClasses());
  }

  AttachmentCardController.prototype._getDefaultClasses = function(){
    return {
      label_class: "attachment-label",
      list_item_class: "attachment-list-item",
      loading_class: "attachment-loading",
      file_class: "attachment-loading-file",
      gif_class: "attachment-loading-gif",
      list_class: "attachment-list"
    }
  }


  AttachmentCardController.prototype._setDefaults = function(opts){
    opts = opts || {};
    var self = this;
    for(var key in this.default_config){
      if(opts.hasOwnProperty(key)){
        self[key] = opts[key];
      }else{
        self[key] = self.default_config[key]
      }
    }
  }

  AttachmentCardController.prototype._event = function(){
    var self = this;
    $(document).on("change", self.el.find("input[type='file']"), function(){
      self.disableLabel();
      self.appendLoadingFile();
      self.submitForm();
    })
  }

  AttachmentCardController.prototype.getFileName = function(){
    var self = this;
    var file = self.el.find("input[type='file']").prop("files");
    if (file.length > 0 && file[0] !== undefined){
      return file[0].name;
    } else {
      return false;
    }
  }

  AttachmentCardController.prototype.disableLabel = function(){
    this.el.find("label." + this.label_class).addClass('disabled');
  }

  AttachmentCardController.prototype.appendLoadingFile = function(){
    this.el.find("ul." + this.list_class).append(
      this.getListItem()
    );
  }

  AttachmentCardController.prototype.getListItem = function(){
   var list_item = $("<li></li>"),
    file = this.getFileName();
   list_item
    .addClass(this.list_item_class + " " + this.loading_class)
    .html(
      $("<strong></strong>")
        .addClass(this.loading_class)
        .html(file)
    )
    .prepend(
      $("<img/>")
        .addClass(this.gif_class)
        .attr("src",this.gif_src)
        .attr("alt","loading")
    )
    return list_item;
  }

  AttachmentCardController.prototype.submitForm = function(){
    var proposalId = $("#proposal_id").attr("data-proposal-id");
    var formData = new FormData();
    var self = this;
    formData.append("attachment", self.el.find('[type="file"]').prop('files')[0] );
    $.ajax({
      url: '/proposals/' + proposalId + '/attachments',  //Server script to process data
      type: 'POST',
      data: formData,
      cache: false,
      headers: {
        'X-Transaction': 'POST Example',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      contentType: false,
      processData: false
    });
  }

  return AttachmentCardController;
}());

window.AttachmentCardController = AttachmentCardController;
