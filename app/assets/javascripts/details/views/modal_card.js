var ModalController;

ModalController = (function(){
  
  function ModalController(el, opts){
    this.el = $(el);
    this.data = { 
      id: 1,
      modal: {
        cancel: ".cancel-modal-content",
        after_cancel: ".after-cancel-modal-content",
        save_confirm: ".save_confirm-modal-content",
        attachment_confirm: ".attachment-modal-content", 
        observer_confirm: ".observer-modal-content", 
        reapproval_confirm: ".reapproval_confirm-modal-content"
      }
    }
    this._setup(el, opts);
    return this;
  }

  ModalController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this._initTriggers();
  }

  ModalController.prototype._initTriggers = function(){
    var self = this;
    $('html').on('click','[data-modal-type]',function(e){
      self._modalClickEvents(e, this);
    });
    this.el.on("modal:close", function(){
      self._closeModal();
    });
  }

  ModalController.prototype._modalClickEvents = function(e, that){
    this.sourceEl = that;
    var preventDefault = $(this.sourceEl).attr('data-modal-default') !== "true";
    if(preventDefault){
      e.preventDefault();
    }
    var modalType = this._getModalType($(this.sourceEl).attr('data-modal-type'));
    this.create(modalType);
  }

  ModalController.prototype._modalEvents = function(el, modalType){
    this._undoButtonSetup(el);
    this._buttonDependence(el);
    this._createCustomEvents(el, modalType);
  }

  ModalController.prototype._createCustomEvents = function(el, modalType){
    var self = this;
    $(el).find('[data-modal-event]').each(function(i, item){
      var event = $(item).attr('data-modal-event');
      $(item).on('click', function(){
        var eventName = modalType + '-modal:' + event;
        self.el.trigger(eventName, [item, self.sourceEl]);
      });
    });
  }

  ModalController.prototype._buttonDependence = function(el){
    checkRequiredForSubmit();
  }

  ModalController.prototype._undoButtonSetup = function(el){
    var self = this;
    $(el).find('.cancel-cancel-link').on('click', function(){
      self._closeModal();
      return false;
    })
  }

  ModalController.prototype.clear = function(){
    $('#modal-wrapper').html("");
  }

  ModalController.prototype.getId = function(){
    var id = this.data.id;
    this.data.id = this.data.id + 1;
    return id;
  }

  ModalController.prototype._closeModal = function(){
    var self = this;
    this.el.trigger('modal:cancel');
    $('#modal-wrapper').addClass('animated fadeOut');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('visible');
      self.clear();
      $('#modal-wrapper').removeClass('animated fadeOut');
    });
  }

  ModalController.prototype._animate = function(){
    $('#modal-wrapper').addClass('animated fadeIn');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('animated fadeIn');
    });
  }

  ModalController.prototype._setupModal = function(modalType){
    var selector = this.data.modal[modalType];
    var content = $(selector).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id).removeClass('modal-template');
    modal.find('.additional-content').html(content);
    return modal;
  }

  ModalController.prototype.create = function(modalType){
    // modalType = this._setCustomModalBehavior(modalType);

    this.clear();
    var modal = this._setupModal(modalType);
    $('#modal-wrapper').append(modal);
    this._modalEvents(modal, modalType);
    this._animate();
    $('#modal-wrapper').addClass('visible');
    this._focus();
  }

  ModalController.prototype._formRequiresReapproval = function(){
    var fields = $("[data-reapproval='true'][data-is-dirrty='true']");
    return fields.length > 0;
  }

  ModalController.prototype._getReapprovalLabels = function(){
    var fields = $("[data-reapproval='true'][data-is-dirrty='true']"),
        field_names = [];
    if(fields.length < 1){
      return false;
    }

    for (var i = fields.length - 1; i >= 0; i--){
      var $field = $(fields[i]);
      if($field && $field.attr("name") && $field.attr("name").indexOf("[amount]") > -1){
        var initAmount = parseFloat($field.attr("data-dirrty-initial-value"));
        var newAmount = parseFloat($field.val());
        if(newAmount < initAmount){
          fields.splice(i, 1);
          continue;
        }
      }
      field_names.push($("label[for='"+$field.attr('id')+"']").text());
    }
    return field_names.join(', ')
  }

  ModalController.prototype._updateModalContent = function(modalType, content){
    var selector = this.data.modal[modalType];
    $(selector + " .custom-modal-content").html(content);
  }

  ModalController.prototype._focus = function(){
    $('#modal-wrapper .popup-content').focus();
  }

  ModalController.prototype._getModalType = function(modal){
    if(modal !== 'save_confirm'){
      return modal
    }
    else if(modal === 'save_confirm'){
      //returns "save_confirm" or "reapproval_confirm"
      if(this._formRequiresReapproval()){
        this._updateModalContent("reapproval_confirm", this._getReapprovalLabels())
        return "reapproval_confirm";  
      }
      else{
        return "save_confirm";
      } 
    }
  }

  return ModalController
}());

window.ModalController = ModalController;
