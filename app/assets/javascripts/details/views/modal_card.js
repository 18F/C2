var modalCardController;

modalCardController = (function(){
  
  function modalCardController(el, opts){
    this._setup(el, opts);
    this.data = { 
      id: 1,
      modal: {
        cancel: {
          title: "You are about to cancel this request.", 
          desc: "Cancelling a request permenantly removes it from C2 and notifies all approvers and observers.",
          content: ".cancel-modal-content"
        }
      }
    }
    return this;
  }

  modalCardController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this.el = typeof el === "string" ? $(el) : el;
    this.cancelButton = this.cancelButton || $(".cancel-request-button");
  }
  
  modalCardController.prototype._setup = function(){
    this._initTriggers();
  }

  modalCardController.prototype._initTriggers = function(){
    var self = this;
    $('[data-modal-type]').on('click', function(e){
      var el = this;
      e.preventDefault();
      var modalType = $(el).attr('data-modal-type');
      self.create(modalType);
    });
  }

  modalCardController.prototype._modalEvents = function(el){
    this._undoButtonSetup(el);
    this._buttonDependence(el);
  }

  modalCardController.prototype._buttonDependence = function(el){
    checkRequiredForSubmit();
  }

  modalCardController.prototype._undoButtonSetup = function(el){
    var self = this;
    $(el).find('.cancel-cancel-link').on('click', function(){
      self._closeModal();
      return false;
    })
  }

  modalCardController.prototype.clear = function(){
    $('#modal-wrapper').html("");
  }

  modalCardController.prototype.getId = function(){
    var id = this.data.id;
    this.data.id = this.data.id + 1;
    return id;
  }

  modalCardController.prototype._closeModal = function(){
    var self = this;
    $('#modal-wrapper').addClass('animated fadeOut');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('visible');
      self.clear();
      $('#modal-wrapper').removeClass('animated fadeOut');
    });
  }

  modalCardController.prototype._animate = function(){
    $('#modal-wrapper').addClass('animated fadeIn');
    $('#modal-wrapper').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
      $('#modal-wrapper').removeClass('animated fadeIn');
    });
  }

  modalCardController.prototype._setupModal = function(modalType){
    var data = this.data.modal[modalType];
    var title = data["title"] || false;
    var description = data["desc"] || false;
    var content = $(data["content"]).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id).removeClass('modal-template');
    modal.find('.popup-content-label').html(title);
    modal.find('.popup-content-desc').html(description);
    modal.find('.additional-content').html(content);
    return modal;
  }

  modalCardController.prototype.create = function(modalType){
    this.clear();
    var modal = this._setupModal(modalType);
    $('#modal-wrapper').append(modal);
    this._modalEvents(modal);
    this._animate();
    $('#modal-wrapper').addClass('visible');
  }

  return modalCardController
}());

window.modalCardController = modalCardController;
