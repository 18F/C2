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

  DetailsRequestCard.prototype.updateField = function(field, value, type){
    this.el.trigger('update:' + type, { field: field, value: value });
  }

  DetailsRequestCard.prototype.updateViewModeContent = function(data){
    var viewEl = this.el.find('#view-request-details')
    var content = data['response'];
    var id = content['id'];
    var self = this;
    $.each(content, function(key, value){
      var field = self.el.selector + ' #' + key + '-' + id;
      var fieldTarget = field + " .detail-display .detail-value";
      if(key === "not_to_exceed") {
        if (value === true){
          value = "Not to exceed";
        } else {
          value = "Exact";
        }
      } else if(key === "date_requested") {
        value = moment(value).format("MMM Do, YYYY")
      } else if(key == "ncr_organization_id") {
        value = $("#ncr_work_order_ncr_organization_id option").text();
      }
      
      if(key === "direct_pay" || key === "recurring"){
        self.updateField(field + ' input[type="checkbox"]', value, "checkbox");
      } else {
        self.updateField(fieldTarget, value, "textfield");
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
