"use strict";

var EditStateController = function () {
  var el = $("#mode-parent");
  this.el = el;
  this._setup();
  return this;
}

EditStateController.prototype._setup = function () {
  this._event();
}

EditStateController.prototype._event = function () {
  this.el.on( "mode:toggle", function( event ) {
    var mode = $( this );
    if ( mode.is( ".edit-mode" ) ) {
      this.state = "edit";
      this.el.trigger("editMode:on");
    } else {
      this.state = "view";
      this.el.trigger("editMode:off");
    }
  });
}

EditStateController.prototype.getState = function () {
  if(this.el.hasClass("edit-mode")){
    return true;
  } else {
    return false;
  }
}

EditStateController.prototype.toggleState = function () {
  if ( this.el.is( ".edit-mode" ) ) {
    this.state = "view";
    this.el.addClass('view-mode').removeClass('edit-mode');
    this.el.trigger("editMode:off");
  } else {
    this.state = "edit";
    this.el.addClass('edit-mode').removeClass('view-mode');
    this.el.trigger("editMode:on");
  }
  var state = this.state;
  console.log('Edit mode: ', state);
}
