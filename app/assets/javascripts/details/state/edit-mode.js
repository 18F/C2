"use strict";

var EditStateController = function (el) {
  this.el = $(el);
  this._setup();
  return this;
}

EditStateController.prototype._setup = function () {
  this.el.on("editMode:toggle", function( e ){
    if ( this.el.is(".edit-mode") ){
      this.el.trigger("editMode:on");
    } else {
      this.el.trigger("editMode:off");
    }
  });
}
