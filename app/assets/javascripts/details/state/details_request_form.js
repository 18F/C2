"use strict";

var DetailsRequestFormState = function (el) {
  this.el = $(el);
  this.data = {
    fieldUID: {}  
  }
  this._setup();
  return this;
}

DetailsRequestFormState.prototype._setup = function(){
}

DetailsRequestFormState.prototype._guid = function(){
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + "-" + s4() + "-" + s4();
};
