var SummaryBar;

SummaryBar = (function() {
  function SummaryBar(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  SummaryBar.prototype._setup = function() {
    this._event();
  };

  SummaryBar.prototype.updateViewContent = function(data) {
    var viewEl = this.el.find('#proposal-title-wrapper .display-content')
    var content = data['response'];
    var id = content['id'];
    var self = this;
    delete content['id'];
    $.each(content, function(key, value){
      var field = '#' + key + '-' + id;
      if( !(value === null) ) {
        self.updateTextFields(field + " .detail-display .detail-value", value);
      }
    });
    this.el.trigger("form:updated");
  };

  SummaryBar.prototype._event = function() {
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
  };

  return SummaryBar;

}());

window.SummaryBar = SummaryBar;
