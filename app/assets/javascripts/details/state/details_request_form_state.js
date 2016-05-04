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
  }

  return DetailsRequestFormState;

}());

window.DetailsRequestFormState = DetailsRequestFormState;
