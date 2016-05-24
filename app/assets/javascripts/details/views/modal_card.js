var modalCardController;

modalCardController = (function(){
  
  function modalCardController(el, opts){
    this._setup(el, opts);
    this.data = { id: 1 }
    return this;
  }

  modalCardController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this.el = typeof el === "string" ? $(el) : el;
    this.cancelButton = this.cancelButton || $(".cancel-request-button");
  }

  modalCardController.prototype._events = function(){
    this._cancelRequestButtonSetup();
    this._undoButtonSetup();
  }

  modalCardController.prototype._cancelRequestButtonSetup = function(){
    var self = this;
    this.cancelButton.on('click', function(){
      self.el.find('textarea').focus();
      return false;
    });
  }

  modalCardController.prototype._undoButtonSetup = function(){
    var self = this;
    this.el.find('.cancel-cancel-link').on('click', function(){
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

  modalCardController.prototype._setupModal = function(params){
    var title = params["title"] || false;
    var description = params["desc"] || false;
    var content = $(params["content"]).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id).removeClass('modal-template');
    modal.find('.popup-content-label').html(title);
    modal.find('.popup-content-desc').html(description);
    modal.find('.additional-content').html(content);
    return modal;
  }

  modalCardController.prototype.create = function(params){
    this.clear();
    var modal = this._setupModal(params);
    $('#modal-wrapper').append(modal);
    this._events();
    this._animate();
    $('#modal-wrapper').addClass('visible');
  }

  return modalCardController
}());

window.modalCardController = modalCardController;
