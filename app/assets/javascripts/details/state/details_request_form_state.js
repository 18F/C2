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

  DetailsRequestFormState.prototype.guid = function(){
    function s4() {
      return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
    }
    return s4() + "-" + s4() + "-" + s4();
  };

  DetailsRequestFormState.prototype._processFields = function(){
    var self = this;
    this.el.find("form, input, textarea, select, radio").each(function(i, item){
      self.createGuid(item);
      self.updateSavedValue(item);
    });
  }

  DetailsRequestFormState.prototype.createGuid = function(item){
    var self = this;
    $(item).attr("data-field-guid", self.guid());
  }

  DetailsRequestFormState.prototype.updateSavedValue = function(item){
    var self = this;
    $(item).attr("data-field-value", $(item).val());
  }

  return DetailsRequestFormState;

}());

window.DetailsRequestFormState = DetailsRequestFormState;
