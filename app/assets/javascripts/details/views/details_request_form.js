var DetailsRequestForm;

DetailsRequestForm = (function(){
  function DetailsRequestForm(el) {
    this.el = $(el);
    this._setup();
    return this;
  }
  
  DetailsRequestForm.prototype._setup = function(){
    this._events();
  }

  DetailsRequestForm.prototype._events = function(){
    var self = this;
    this.el.find("input, textarea, select, radio").on("change keypress blur focus keyup", function(e){
      var el = this;
      self.fieldChanged(e, el)
    });
  }

  DetailsRequestForm.prototype.fieldChanged = function(e, el){
    this.el.trigger("form:changed"); 
  }

  return DetailsRequestForm;

}());

window.DetailsRequestForm = DetailsRequestForm;
