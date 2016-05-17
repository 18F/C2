var DetailsRequestCard;

DetailsRequestCard = (function(){
  function DetailsRequestCard(el) {
    this.el = $(el);
    this._setup();
    this.data = {
      buttonText: "Modify",
      gridLayout: "two-column"
    }
    return this;
  }
  
  DetailsRequestCard.prototype._setup = function(){
    this._events();
  }

  DetailsRequestCard.prototype._events = function(){
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
      self.el.trigger('edit-toggle:trigger');
    });
  }

  DetailsRequestCard.prototype.toggleMode = function(mode){
    switch (mode){
      case 'view':
        this.data.buttonText = "Modify";
        this.data.gridLayout = "two-column";
        break;
      case 'edit':
        this.data.buttonText = "Cancel";
        this.data.gridLayout = "one-column";
        break;
    }
    this.updateCard();
  }

  DetailsRequestCard.prototype.updateButton = function(){
    text = this.data.buttonText;
    this.toggleButtonText(text);
  }

  DetailsRequestCard.prototype.updateGrid = function(){
    var klass = "grid-layout small-up-1";
    switch (this.data.gridLayout) {
      case "one-column":
          klass = klass + "medium-up-1";
        break;
      case "two-column":
          klass = klass + "medium-up-2";
        break;
    }
    this.el.find('.grid-layout').attr('class', klass);
  }

  DetailsRequestCard.prototype.updateCard = function(){
    console.log(this.data);
    this.updateGrid();
    this.updateButton();
  }

  DetailsRequestCard.prototype.toggleButtonText = function(text){
    this.el.find('.edit-toggle span').text(text)
  }

  DetailsRequestCard.prototype.updateContentFields = function(field, value){
    $(field).text(value);
  }

  DetailsRequestCard.prototype.updateViewModeContent = function(data){
    console.log(data);
    var viewEl = this.el.find('#view-request-details')
    var content = data['response'];
    var id = content['id'];
    var self = this;
    delete content['id'];
    $.each(content, function(key, value){
      var field = '#' + key + '-' + id;
      if(!(value === null)){
        self.updateContentFields(field, value);
      }
    });
    this.el.trigger("form:updated");
  }

  DetailsRequestCard.prototype.setMode = function(type){
    if (type === "view"){
      this.el.removeClass('edit-fields');
      this.el.addClass('view-fields');
    } else if (type === "edit") {
      this.el.removeClass('view-fields');
      this.el.addClass('edit-fields');
    }
  }

  DetailsRequestCard.prototype.fieldChanged = function(e, el){
    this.el.trigger("form:changed"); 
  }

  return DetailsRequestCard;

}());

window.DetailsRequestCard = DetailsRequestCard;
