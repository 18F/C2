var modalCardController;

modalCardController = (function(){
  
  function modalCardController(el, opts){
    this._setup(el, opts);
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
  return modalCardController
}());

window.modalCardController = modalCardController;
