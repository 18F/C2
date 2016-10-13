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
    this.el.on( "details-form:save", function( event ) {
      self.validateFormFields();
    });
    this.el.on( "details-form:respond", function( event, data ) {
      console.log(data);
      self.receiveResponse(data);
    });
    this.el.on( "details-form:validate", function( event, data ) {
      console.log(data);
      switch (data['status']){
        case "success":
          self.submitFormFields(data);
          self.el.find('form.request-details-form').submit();
          break;
        case "error":
          self.el.trigger( "details-form:error", data );
          break;
        default:
          break;
      }
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

  DetailsSave.prototype._prepareFormData = function(){
    var formData = this.el.find('form.request-details-form').serialize();
    var dataEl = this.dataEl;
    console.log(formData);
    return formData;
  }

  DetailsSave.prototype.submitFields = function(params){
    var url = this.el.find('form.request-details-form').attr("action");
    var formData = this._prepareFormData();
    console.log(formData);
    $.ajax({
      url: url + params,
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      type: 'POST',
      data: formData
    });
  }

  DetailsSave.prototype.validateFormFields = function(){
    this.submitFields("?validate=true");
  }

  DetailsSave.prototype.submitFormFields = function(){
    this.submitFields("");
  }

  return DetailsSave;

}());

window.DetailsSave = DetailsSave;
