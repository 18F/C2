var CancelCardController;

CancelCardController = (function(){
  
  function CancelCardController(el, opts){
    this._setup(el, opts);
    this._events();
    return this;
  }

  CancelCardController.prototype._setup = function(el, opts){
    $.extend(this, opts);
    this.el = typeof el === "string" ? $(el) : el;
    this.el.hide();
    this.cancelButton = this.cancelButton || $(".cancel-request-button");
  }

  CancelCardController.prototype._events = function(){
    this._cancelRequestButtonSetup();
    this._undoButtonSetup();
  }

  CancelCardController.prototype._cancelRequestButtonSetup = function(){
    var self = this;
    this.cancelButton.on('click', function(){
      self.el.show();
      self.el.find('textarea').focus();
      return false;
    });
  }

  CancelCardController.prototype._undoButtonSetup = function(){
    var self = this;
    this.el.find('.cancel-cancel-link').on('click', function(){
      self.el.hide();
      return false;
    })
  }
  return CancelCardController
}());

window.CancelCardController = CancelCardController;
