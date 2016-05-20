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
    this.saveButton = this.el.find( '.save-button button' );
    this.saveButton.ladda( 'bind' );
    this.saveButtonLadda = this.saveButton.ladda();
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
    this.el.find('.' + buttonName + '-button button').on('click', function(){
      self.el.trigger('action-bar-clicked:' + buttonName);
    });
  }

  ActionBar.prototype._saveTriggered = function(buttonName) {
    var actionBar = this;
    actionBar.el.on('action-bar-clicked:saving', function(){
      actionBar.saveButtonLadda.ladda( 'start' );
    })
    actionBar.el.on('action-bar-clicked:saved', function(){
      actionBar.saveButtonLadda.ladda( 'stop' );
      actionBar.viewMode();
    })
  }

  ActionBar.prototype.cancelDisable = function() {
    this.el.find('.cancel-button button').attr("disabled", "disabled");
  }

  ActionBar.prototype.cancelActive = function() {
    this.el.find('.cancel-button button').attr("disabled", false);
  }

  ActionBar.prototype.viewMode = function() {
    this.cancelDisable();
    $('.action-bar-template').removeClass('edit-actions');
  }

  ActionBar.prototype.editMode = function() {
    this.cancelActive();
    $('.action-bar-template').addClass('edit-actions');
  };

  ActionBar.prototype.saveDisable = function() {
    this.el.find('.save-button button').attr("disabled", "disabled");
  }

  ActionBar.prototype.saveActive = function() {
    this.el.find('.save-button button').attr("disabled", false);
  };

  return ActionBar;

}());

window.ActionBar = ActionBar;
