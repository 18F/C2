var modalCardController;

modalCardController = (function(){
  
  function modalCardController(el, opts){
    this._setup(el, opts);
    this.data = { id: 1 }
    this._events();
    return this;
  }

  modalCardController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this.el = typeof el === "string" ? $(el) : el;
    this.el.hide();
    this.cancelButton = this.cancelButton || $(".cancel-request-button");
  }

  modalCardController.prototype._events = function(){
    this._cancelRequestButtonSetup();
    this._undoButtonSetup();
  }

  modalCardController.prototype._cancelRequestButtonSetup = function(){
    var self = this;
    this.cancelButton.on('click', function(){
      self.el.show();
      self.el.find('textarea').focus();
      return false;
    });
  }

  modalCardController.prototype._undoButtonSetup = function(){
    var self = this;
    this.el.find('.cancel-cancel-link').on('click', function(){
      self.el.hide();
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

  modalCardController.prototype.create = function(params){
    this.clear();
    var title = params["title"] || false;
    var description = params["desc"] || false;
    var content = $(params["content"]).clone() || false;
    var id = this.getId();
    var modal = $('#modal-template').clone().attr('id', "modal-el-" + id);
    modal.find('.popup-content-label').html(title);
    modal.find('.popup-content-desc').html(description);
    modal.find('.additional-content').html(content);
    $('#modal-wrapper').append(modal);
  }

  return modalCardController
}());

window.modalCardController = modalCardController;
