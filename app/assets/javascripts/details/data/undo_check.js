var UndoCheck;

UndoCheck = (function(){
  function UndoCheck(el) {
    this.el = $(el);
    this._setup()
    this._events()
  }

  UndoCheck.prototype._setup = function(){
    this.startValue = this.el.html();
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

  UndoCheck.prototype.hasChanged = function(){
    this.newValue = this.el.html();
    if(this.startValue !== this.newValue){
      return true;
    } else {
      return false;
    }
  }

  UndoCheck.prototype.saveState = function(){

  }

  UndoCheck.prototype.cancelChanges = function(){
    
  }

  return UndoCheck;

}());

window.UndoCheck = UndoCheck;
