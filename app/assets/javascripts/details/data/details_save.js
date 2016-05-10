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
    this.el.on( "details-form:save", function( event, data ) {
      self.saveDetailsForm();
    });
    this.el.on( "details-form:respond", function( event, data ) {
      self.receiveResponse(data);
    });
  }

  DetailsSave.prototype.receiveResponse = function(data){
    var self = this;
    console.log(data);
    switch (data['status']){
      case "success":
        console.log('Success response');
        self.el.trigger( "details-form:success", data );
        break;
      case "error":
        console.log('Error response');
        self.el.trigger( "details-form:error", data );
        break;
      default:
        console.log('Unknown response');
        break;
    }
  }

  DetailsSave.prototype.saveDetailsForm = function(){
    this.el.find('form').submit();
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
