"use strict";

var DetailsRequestForm = function (el) {
  this.el = $(el);
  this.data = {}
  this._setup();
  return this;
}

DetailsRequestForm.prototype._setup = function(){
  this._createGuid();
  this.data.$el = this.el.find('form');
}

DetailsRequestForm.prototype._guid = function(){
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + "-" + s4() + "-" + s4();
};

DetailsRequestForm.prototype._createGuid = function(){
  this.el.find("form, input, textarea, select, radio").each(function(i, item){
    $(item).attr("data-field-guid", detailsApp.guid());
  });
}
