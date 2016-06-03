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
    this.el.on('update:textfield', function(event, data){
      self.updateTextFields(data)
    });
    this.el.on('update:checkbox', function(event, data){
      self.updateCheckbox(data)
    });
  }

  UpdateView.prototype.updateTextFields = function(data){
    var value = data['value'];
    var selector = data['field'];
    var key = this.el.find(selector).parents('.detail-wrapper').attr('data-key');
    if(key){
      console.log(selector);
      console.log(key);
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
