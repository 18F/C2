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
    if(this.startValue != this.newValue){
      return true;
    } else {
      return false;
    }
  }

  UndoCheck.prototype.saveState = function(){
    this.startValue = this.newValue;
  }

  UndoCheck.prototype.cancelChanges = function(){
    var self = this;
    this.el.html(self.startValue);
    this.resetSelectize();
    this.removeOldSelectize();
    this.resetFilters();
    self.startValue = this.el.html();
  }

  UndoCheck.prototype.resetFilters = function(){
    Filter.setupFilter()
  }

  UndoCheck.prototype.resetSelectize = function(){
    this.el.find(".js-selectize").each(function(i, el) {
      var selectizer;
      selectizer = new Selectizer(el);
      selectizer.enable();
      return selectizer.add_label();
    });
  }

  UndoCheck.prototype.removeOldSelectize = function(){
    this.el.find('.form-group .js-selectize').not('.selectized').remove();
  }

  return UndoCheck;

}());

window.UndoCheck = UndoCheck;
