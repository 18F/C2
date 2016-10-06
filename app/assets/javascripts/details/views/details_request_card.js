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

    this._summaryBarEvents();
  }

  DetailsRequestCard.prototype._summaryBarEvents = function(){
    var titleWrap = this.el.find('.c2n_header');
    this.el.find('#header-edit-text').on('click', function(){
      if ( titleWrap.hasClass('view-title') ){
        titleWrap.removeClass('view-title')
        titleWrap.addClass('edit-title')
      } else {
        titleWrap.addClass('view-title')
        titleWrap.removeClass('edit-title')
      }
    })
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
    var klass = "grid-layout";
    // var klass = "grid-layout small-up-1 ";
    switch (this.data.gridLayout) {
      case "one-column":
          klass = klass;
        break;
      case "two-column":
          klass = klass;
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

  DetailsRequestCard.prototype.updateBoolean = function(value, yesCondition, noCondition){
    if(value){
      return yesCondition;
    } else {
      return noCondition;
    }
  }

  DetailsRequestCard.prototype.defineValue = function(key, value){
    var self = this;
    // if(key === "not_to_exceed") {
      // value = self.updateBoolean(value, 'Not to exceed', 'Exact');
    // } else if(key === "is_tock_billable") {
      // value = self.updateBoolean(value, 'Yes', 'No');

    // Need test for each condition
    // Need to finish rest

    } else if(key === "date_requested") {
      value = moment(value).format("MMM Do, YYYY")
    // } else if(key === "ncr_organization_id") {
      // value = $("#ncr_work_order_ncr_organization_id option").text();
    }
    return value;
  }

  DetailsRequestCard.prototype.updateViewModeContent = function(data){
    var content = this.formatData(data['display']);
    var id = content['id'];
    var self = this;
    $.each(content, function(key, value){
      var field = self.el.selector + ' #' + key + '-' + id;
      var fieldTarget = field + " .detail-display .detail-value";
      value = self.defineValue(key, value);
      if(key === "direct_pay" || key === "recurring"){
        self.updateField(field + ' input[type="checkbox"]', value, "checkbox");
      } else {
        self.updateField(fieldTarget, value, "textfield");
      }
    });
    this.el.trigger("form:updated", data['response']);
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

  DetailsRequestCard.prototype.formatData = function(data){
    data.amount = this.formatMoney(data.amount, 2, '.', '');
    return data;
  }

  DetailsRequestCard.prototype.formatMoney = function(num,c, d, t){
    var n = num;

    var s = n < 0 ? "-" : "",
    i = parseInt(n = Math.abs(+n || 0).toFixed(c), 10) + "",
    j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };

  return DetailsRequestCard;

}());

window.DetailsRequestCard = DetailsRequestCard;
