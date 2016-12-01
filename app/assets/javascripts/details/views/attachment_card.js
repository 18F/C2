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
    this.clientCodeValidation();
  }

  AttachmentCardController.prototype.clientCodeValidation = function(){
    $('#new_gsa18f_event [name="attachments[]"]').first().attr('required', 'required')
    var attachment = document.querySelector('#new_gsa18f_event [name="attachments[]"][required="required"]');
    if (attachment !== null && attachment !== undefined){
      $('.submit-button [type="submit"]').on('click', function(){
        if (!attachment.validity.valid){
          $('[required="required"]').each(function(i, item){
            if(!item.validity.valid){
              $('[required="required"]').each(function(i, item){
                if(!item.validity.valid){
                  $(item).closest('.detail-wrapper, .form-group').css('backgroundColor', "yellow");
                  window.setTimeout(function(){
                    $(item).closest('.detail-wrapper, .form-group').css('backgroundColor', "white");
                  }, 1000);
                } else {
                  $(item).closest('.detail-wrapper, .form-group').css('backgroundColor', "white");
                }
              })
            }
          })
        }
      });
    }
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
      buttonSelector: "label.attachment-label",
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
    var $body = $("body");
    if($body.hasClass('action-new')){
      $('input[type="file"]').change(function(e){
        var fileName = "";
        if(e.target.files.length > 0){
          fileName = e.target.files[0].name;
        }
        $(this).closest('li').find('.file-name').html(fileName)
      });
    } else if($body.hasClass('action-show')) {
      $(document).on("change", self.el.find("input[type='file']"), function(){
        if (self.el.find("input[type='file']").prop("files").length !== 0){
          self.disableLabel();
          self.appendLoadingFile();
          self.submitForm();
        }
      })
    }
  }


  AttachmentCardController.prototype.getFileName = function(){
    var self = this;
    var file = self.el.find("input[type='file']");
    return file.prop("files")[0].name;
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
    }).done(function(){
      $('body').find('form.request-details-form').submit();
    });
  }

  return AttachmentCardController;
}());

window.AttachmentCardController = AttachmentCardController;
