var DetailsRequestCard;

DetailsRequestCard = (function(){
  function DetailsRequestCard(el) {
    this.el = $(el);
    this._setup();
    this.data = {
      gridLayout: "two-column"
    }
    return this;
  }

  DetailsRequestCard.prototype._setup = function(){
    this._events();
  }

  DetailsRequestCard.prototype._events = function(){
    var self = this;

    this.el.find('.edit-toggle').on('click', function(e){
      e.preventDefault();
      self.el.trigger('edit-toggle:trigger');
    });
  }

  DetailsRequestCard.prototype.toggleMode = function(mode){
    switch (mode){
      case 'view':
        this.data.gridLayout = "two-column";
        break;
      case 'edit':
        this.data.gridLayout = "one-column";
        break;
    }
    this.updateCard();
  }

  DetailsRequestCard.prototype.updateGrid = function(){
    var klass = "grid-layout small-up-1 ";
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
    this.updateGrid();
  }

  DetailsRequestCard.prototype.toggleButtonText = function(text){
    this.el.find('.edit-toggle span').text(text)
  }


  DetailsRequestCard.prototype.updateTextFields = function(field, value){
    this.el.find(field).html(value);
  }

  DetailsRequestCard.prototype.updateCheckbox = function(field, value){
    $(field).prop('checked', value);
  }

  DetailsRequestCard.prototype.updateViewModeContent = function(data){
    var viewEl = this.el.find('#view-request-details')
    var content = data['response'];
    var id = content['id'];
    var self = this;
    $.each(content, function(key, value){
      var field = '#' + key + '-' + id;
      var fieldTarget = field + " .detail-display .detail-value";
      if(key === "not_to_exceed") {
        if (value === true){
          value = "Not to exceed";
        } else {
          value = "Exact";
        }
      } else if(key === "date_requested") {
        value = moment(value).format("MMM Do YYYY")
      }
      
      if(key === "direct_pay" || key === "recurring"){
        self.updateCheckbox(field + ' input[type="checkbox"]', value);
      } else {
        self.updateTextFields(fieldTarget, value);
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

  return DetailsRequestCard;

}());

window.DetailsRequestCard = DetailsRequestCard;
