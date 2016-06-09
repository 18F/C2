var DetailsSave;
DetailsSave = (function() {

  function DetailsSave(el, dataEl) {
    this.el = $(el);
    this.dataEl = $(dataEl);
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
    var formData = this.dataEl.find('form').serialize();
    $.ajax({
      url: this.el.find('form')[0].action,
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      type: 'POST',
      data: formData
    });
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
