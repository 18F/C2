var DetailsRequestFormState;

DetailsRequestFormState = (function(){
  function DetailsRequestFormState(el) {
    this.el = $(el);
    this.data = {
      fieldUID: {}  
    }
    this._setup();
    return this;
  }
  
  DetailsRequestFormState.prototype._setup = function(){
    this._processFields();
  }

  DetailsRequestFormState.prototype._processFields = function(){
    var self = this;
    this.el.find("form, input, textarea, select, radio").each(function(i, item){
    
    });
  }

  return DetailsRequestFormState;

}());

window.DetailsRequestFormState = DetailsRequestFormState;
