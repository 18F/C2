var DetailsSave;
DetailsSave = (function() {
  
  function DetailsSave(option = {}){
    this._blastOff();
  }

  DetailsSave.prototype._blastOff = function(){
    this._events();
  }

  DetailsSave.prototype._events = function(){
    this.el.on( "details-save:toggle", function( event ) {
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

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
