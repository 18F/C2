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
    this._setupActionBarClicked('save');
    this._setupActionBarClicked('cancel');
  };

  ActionBar.prototype._setupActionBarClicked = function(buttonName) {
    var self = this;
    this.el.find('.' + buttonName + '-button input').on('click', function(){
      self.el.trigger('actionBarClicked:' + buttonName);
    });
  }

  ActionBar.prototype.viewMode = function() {
    this.el.removeClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", "disabled");
  };

  ActionBar.prototype.editMode = function() {
    this.el.addClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", false);
  };

  return ActionBar;

}());

window.ActionBar = ActionBar;
