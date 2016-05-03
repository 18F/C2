var ActionBar;

ActionBar = (function() {
  function ActionBar(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ActionBar.prototype._setup = function() {
    this._event();
    this.viewMode();
  };

  ActionBar.prototype._event = function() {
    this.el.find('.save-button input').on('click', function(){
      this.el.trigger('actionBar:saveClicked');
      console.log('Clicked');
    });

    this.el.find('.cancel-button input').on('click', function(){
      this.el.trigger('actionBar:cancelClicked');
      console.log('Clicked');
    });
  };

  ActionBar.prototype.viewMode = function() {
    this.el.removeClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", "disabled");
  };

  ActionBar.prototype.editMode = function() {
    this.el.addClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", false);
  };

  return ActionBar;

})();

window.ActionBar = ActionBar;
