var EditStateController;

EditStateController = (function(){
  function EditStateController = function(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  EditStateController.prototype._setup = function () {
    this.state = "view";
    this._event();
  }

  EditStateController.prototype._event = function () {
    this.el.on( "edit-mode:toggle", function( event ) {
      var mode = $( this );
      if ( mode.is( ".edit-mode" ) ) {
        this.state = "edit";
        this.el.trigger("edit-mode:on");
      } else {
        this.state = "view";
        this.el.trigger("edit-mode:off");
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
      this.stateTo('view');
    } else if ( this.el.is( ".view-mode" ) ){
      this.stateTo('edit');
    }
    var state = this.state;
  }

  EditStateController.prototype.stateTo = function (state) {
    this.state = state;
    this.el.addClass(state + '-mode');
    
    switch(state) {
      case "view":
        this.el.removeClass('edit-mode');
        this.el.trigger("edit-mode:off");
        break;
      case "edit":
        this.el.removeClass('view-mode');
        this.el.trigger("edit-mode:on");
        break;
    }
  }

  return EditStateController;

})();

window.EditStateController = EditStateController;
