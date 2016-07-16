var DetailsSave;
DetailsSave = (function() {

  function DetailsSave(el, dataEl) {
    this.el = $(el);
    this.dataEl = $(dataEl);
    this._blastOff();
  }

  DetailsSave.prototype._blastOff = function(){
    console.log('DetailsSave: _blastOff');
    this._events();
  }

  DetailsSave.prototype._events = function(){
    console.log('DetailsSave: _events');
    var self = this;
    this.el.on( "details-form:save", function( event, data ) {
      console.log('Event: details-form:save');
      self.saveDetailsForm(data);
    });
    this.el.on( "details-form:respond", function( event, data ) {
      console.log('Event: details-form:respond');
      self.receiveResponse(data);
    });
    this.el.on( "details-form:validate", function( event, data ) {
      console.log('Event: details-form:respond');
      self.receiveValidation(data);
    });
    this.el.on( "details-form:success", function( event, data ) {
      console.log('Event: details-form:success');
    });
    this.el.on( "details-form:error", function( event, data ) {
      console.log('Event: details-form:error');
    });
  }

  DetailsSave.prototype.receiveValidation = function(data){
    console.log('DetailsSave: receiveValidation');
    var self = this;
    switch (data['status']){
      case "success":
        self.el.find('form').submit();
        break;
      case "error":
        self.el.trigger( "details-form:error", data );
        break;
      default:
        break;
    }
  }

  DetailsSave.prototype.receiveResponse = function(data){
    console.log('DetailsSave: receiveResponse');
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

  DetailsSave.prototype._prepareFormData = function(){
    console.log('DetailsSave: _prepareFormData');
    var formData = this.el.find('form').serialize();
    var dataEl = this.dataEl;
    formData = formData + '&' + dataEl.find('form [data-is-dirrty]').serialize();
    console.log(formData);
    return formData;
  }

  DetailsSave.prototype.validateFields = function(url, formData){
    $.ajax({
      url: url + "?validate=true",
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      type: 'POST',
      data: formData
    });
  }

  DetailsSave.prototype.saveDetailsForm = function(data){
    console.log('DetailsSave: saveDetailsForm');
    var self = this;
    var formData = this._prepareFormData();
    console.log('Submitting form');
    var url = self.el.find('form').attr("action");
    self.validateFields(url, formData);
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
