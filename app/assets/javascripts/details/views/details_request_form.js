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
      self._debounce.(function(){
        self.fieldChanged(e, el);
      }, 100);
    });
  }

  DetailsRequestForm.prototype._debounce function(func, wait, immediate) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  DetailsRequestForm.prototype.fieldChanged = function(e, el){
    this.el.trigger("form:changed"); 
  }

  return DetailsRequestForm;

}());

window.DetailsRequestForm = DetailsRequestForm;
