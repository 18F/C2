var DetailsSave;
DetailsSave = (function() {
  
  function DetailsSave(el) {
    this.el = $(el);
    this._blastOff();
  }

  DetailsSave.prototype._blastOff = function(){
    this._events();
  }

  DetailsSave.prototype._events = function(){
    var self = this;
    this.el.on( "details-form:save", function( event ) {
      self.saveDetailsForm();
    });
  }

  DetailsSave.prototype.saveDetailsForm = function(){
    this.el.find('form').submit();
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
