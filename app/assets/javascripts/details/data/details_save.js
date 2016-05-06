var DetailsSave;
DetailsSave = (function() {
  
  function DetailsSave(option = {}){
    this._blastOff();
  }

  DetailsSave.prototype._blastOff = function(){
    this._events();
  }

  DetailsSave.prototype._events = function(){
    this.el.on( "details-form:save", function( event ) {
      this.el.trigger("edit-mode:off");
    });
  }

  DetailsSave.prototype.saveDetailsForm = function(){
    this.el.trigger( "details-form:save" );
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
