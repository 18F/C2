var AttachmentCardController;

AttachmentCardController = (function(){

  function AttachmentCardController(el, opts){
    this.el = typeof el === "string" ? $(el) : el;
    this._setup(opts);
    return this;
  }

  AttachmentCardController.prototype._setup = function(opts){
    opts = opts || {};
    this.default_config = {label_class: "attachment-label", list_item_class: "attachment-list-item", loading_class: "attachment-loading", file_class: "attachment-loading-file", gif_class: "attachment-loading-gif",list_class: "attachment-list", form_id: "#new_attachment", gif_src: "/assets/spin.gif"};
    this._setDefaults(opts);
    this._event();
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
    $(document).on("change",this.form_id + " input[type='file']", function(){
      self.disableLabel();
      self.appendLoadingFile();
      self.submitForm();
    })
  }

  AttachmentCardController.prototype.getFileName = function(){
    return this.el.find(this.form_id + " input[type='file']").val().split("\\").pop();
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
    this.el.find("form" + this.form_id).submit();
  }

  return AttachmentCardController;
}());

window.AttachmentCardController = AttachmentCardController;
