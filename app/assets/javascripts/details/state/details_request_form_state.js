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
    this._createGuid();
  }

  DetailsRequestFormState.prototype.guid = function(){
    function s4() {
      return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    }
    return s4() + "-" + s4() + "-" + s4();
  };

  DetailsRequestFormState.prototype._createGuid = function(){
    var self = this;
    this.el.find("form, input, textarea, select, radio").each(function(i, item){
      $(item).attr("data-field-guid", self.guid());
    });
  }

  return DetailsRequestFormState;

}());

window.DetailsRequestFormState = DetailsRequestFormState;
