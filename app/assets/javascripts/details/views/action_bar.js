var ActionBar;

ActionBar = (function() {
  function ActionBar(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ActionBar.prototype._setup = function() {
    this.viewMode();
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
