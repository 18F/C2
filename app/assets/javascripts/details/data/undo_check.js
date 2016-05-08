var UndoCheck;

UndoCheck = (function(){
  function UndoCheck(el) {
    this.el = $(el);
    this._setup()
    this._events()
  }

  UndoCheck.prototype._setup = function(){
    var self = this;
    this.newValue = "";
    this.saveState();
  }
  
  UndoCheck.prototype._events = function(){
    var self = this;
    this.el.on('undo-check:save', function(){
      self.saveState();
    });
    this.el.on('undo-check:cancel', function(){
      self.cancelChanges();
    });
  }

  UndoCheck.prototype.saveState = function(){
    this.startValue = this.el.html();
  }

  UndoCheck.prototype.cancelChanges = function(){
    var self = this;
    this.text.html(self.startValue);
  }

  return UndoCheck;

}());

window.UndoCheck = UndoCheck;
