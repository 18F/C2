var DetailsSave;
DetailsSave = (function() {

  function DetailsSave(el, dataEl) {
    this.el = $(el);
    this.dataEl = this.el.find('form.request-details-form');
    this._blastOff();
  }

  DetailsSave.prototype._blastOff = function(){
    this._events();
  }

  DetailsSave.prototype._events = function(){
    var self = this;
    this.el.on( "details-form:save", function( event, data ) {
      self.saveDetailsForm(data);
    });
    this.el.on( "details-form:respond", function( event, data ) {
      self.receiveResponse(data);
    });
    this.el.on( "details-form:success", function( event, data ) {

    });
    this.el.on( "details-form:error", function( event, data ) {

    });
  }

  DetailsSave.prototype.receiveResponse = function(data){
    var self = this;
    switch (data['status']){
      case "success":
        self.el.trigger( "details-form:success", data );
        break;
      case "error":
        self.el.trigger( "details-form:error", data );
        break;
      default:
        break;
    }
  }

  DetailsSave.prototype.saveDetailsForm = function(data){
    var self = this;
    this.dataEl.submit();
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
