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

  SummaryBar.prototype._event = function() {
    var self = this;
    this.el.find('#header-edit-text').on('click', function(){
      if ( self.el.find('.summary-card . c2n_header').hasClass('view-title') ){
        self.el.find('.summary-card . c2n_header').removeClass('view-title')
        self.el.find('.summary-card . c2n_header').addClass('edit-title')
      } else {
        self.el.find('.summary-card . c2n_header').addClass('view-title')
        self.el.find('.summary-card . c2n_header').removeClass('edit-title')
      }
    })
  };

  return SummaryBar;

}());

window.SummaryBar = SummaryBar;
