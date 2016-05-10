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
    this._saveTriggered();
  };

  /**
   * .on("action-bar-clicked:save")
   * .on("action-bar-clicked:cancel")
   */
  ActionBar.prototype._setupActionBarClicked = function(buttonName) {
    var self = this;
    this.el.find('.' + buttonName + '-button input').on('click', function(){
      self.el.trigger('action-bar-clicked:' + buttonName);
    });
  }

  ActionBar.prototype._saveTriggered = function(buttonName) {
    var actionBar = this;
    actionBar.el.on('action-bar-clicked:saved', function(){
      actionBar.viewMode();
    })
  }

  ActionBar.prototype.cancelDisable = function() {
    this.el.find('.cancel-button input').attr("disabled", "disabled");
  }

  ActionBar.prototype.cancelActive = function() {
    this.el.find('.cancel-button input').attr("disabled", false);
  }

  ActionBar.prototype.viewMode = function() {
    this.el.removeClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", "disabled");
  }

  ActionBar.prototype.editMode = function() {
    this.el.addClass('edit-actions');
    this.el.find('.save-button input').attr("disabled", false);
  };

  return ActionBar;

}());

window.ActionBar = ActionBar;
