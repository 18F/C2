var UpdateView;
UpdateView = (function() {

  function UpdateView(el) {
    this.el = $(el);
    this._blastOff();
  }

  UpdateView.prototype._blastOff = function(){
    this._events();
  }

  UpdateView.prototype._events = function(){
    var self = this;
    var el = this.el;
    el.on('field_update:textfield', function(event, data){
      self.updateTextFields(data);
    });
    el.on('field_update:checkbox', function(event, data){
      self.updateCheckbox(data);
    });
  }

  UpdateView.prototype.updateTextFields = function(data){
    var value = data['value'];
    var selector = data['field'];
    var key = this.el.find(selector).parents('.detail-wrapper').attr('data-key');
    if(key){
      key = JSON.parse(key);
      value = key[String(value)];
    }
    this.el.find(data['field']).html(value);
  }


  UpdateView.prototype.updateCheckbox = function(data){
    this.el.find(data['field']).prop('checked', data['value']);
  }

  return UpdateView;

}());

window.UpdateView = UpdateView;
