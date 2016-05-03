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
    var self = this;
    this.el.find('.save-button input').on('click', function(){
      self.el.trigger('actionBarClicked:save');
    });

    this.el.find('.cancel-button input').on('click', function(){
      self.el.trigger('actionBarClicked:cancel');
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
