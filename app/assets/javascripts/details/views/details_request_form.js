var DetailsRequestForm;

DetailsRequestForm = (function(){
  function DetailsRequestForm(el) {
    this.el = $(el);
    this._setup();
    return this;
  }
  
  DetailsRequestForm.prototype._setup = function(){
    this._events();
  }

  DetailsRequestForm.prototype._events = function(){
    var self = this;
    this.el.find("input, textarea, select, radio").on("change keyup", function(e){
      var el = this;
      switch(el.nodeName){
        case "TEXTAREA":
          $(el).text(el.value);
          break;
        case "INPUT":
          switch(el.type){
            case "radio":
              $(el).attr('checked', 'true');
              break;
            case "checkbox":
              if (el.checked === true){
                $(el).attr('checked', 'false');
              } else {
                $(el).attr('checked', 'true');
              }
              break;
          }
          break;
        default:
          break;
      }
      self.fieldChanged(e, el);
    });

    this.el.find('.edit-toggle').on('click', function(e){
      e.preventDefault();
      self.el.toggle('edit-toggle:trigger');
    });
  }

  DetailsRequestForm.prototype.setMode = function(type){
    if (type == "view"){
      this.el.removeClass('edit-fields');
      this.el.addClass('view-fields');
    } else if (type == "edit") {
      this.el.removeClass('view-fields');
      this.el.addClass('edit-fields');
    }
  }

  DetailsRequestForm.prototype.fieldChanged = function(e, el){
    this.el.trigger("form:changed"); 
  }

  return DetailsRequestForm;

}());

window.DetailsRequestForm = DetailsRequestForm;
