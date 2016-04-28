"use strict";

var DetailsRequestForm = function (el) {
  this.el = $(el);
  this.data = {}
  this._setup();
  return this;
}

DetailsRequestForm.prototype._setup = function(){
  this.data.$el = this.el.find('form');
}
