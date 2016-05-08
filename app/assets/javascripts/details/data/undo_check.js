var UndoCheck;

UndoCheck = (function(){
  function UndoCheck(el) {
    this.el = $(el);
    this.stack = new Undo.Stack();
    this._setup()
    this._events()
  }

  UndoCheck.prototype._setup = function(){
    var self = this;
    this.text = el;
    this.newValue = "";
    this.saveState();
  }
  
  UndoCheck.prototype._events = function(){
    var self = this;
    this.el.on('undoCheck:save', function(){
      self.saveState();
    });
    this.el.on('undoCheck:cancel', function(){
      self.cancelChanges();
    });
  }

  UndoCheck.prototype.saveState = function(){
    this.startValue = text.html();
  }

  UndoCheck.prototype.cancelChanges = function(){
    var self = this;
    this.text.html(self.startValue);
  }

  return UndoCheck;

}());

window.UndoCheck = UndoCheck;
