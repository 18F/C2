var ActionBar;

ActionBar = (function() {
  function ActionBar(el) {
    this.el = $(el);
    this.lastClick = new Date();
    this._setup();
    return this;
  }

  ActionBar.prototype._setup = function() {
    console.log("ActionBar: _setup");
    this._event();
    this.setMode('view');
  };

  ActionBar.prototype._event = function() {
    console.log("ActionBar: _event");
    this.saveButton = this.el.find( '.save-button button' );
    this.saveButton.ladda( 'bind' );
    this.saveButtonLadda = this.saveButton.ladda();
    this._setupActionBarClicked('save');
    this._setupActionBarClicked('cancel');
    this._setupActionBarClicked('edit');
    this._saveTriggered();
  };

  ActionBar.prototype.updateClick = function() {
    this.lastClick = new Date();
  }

  /**
   * .on("action-bar-clicked:save")
   * .on("action-bar-clicked:cancel")
   */
  ActionBar.prototype._setupActionBarClicked = function(buttonName) {
    console.log("ActionBar: _setupActionBarClicked");
    var self = this;
    this.el.find('.' + buttonName + '-button button').on('click', function(){
      self.updateClick();
      self.el.trigger('action-bar-clicked:' + buttonName);
    });
  }

  ActionBar.prototype._saveTriggered = function(buttonName) {
    console.log("ActionBar: _saveTriggered");
    var actionBar = this;
    actionBar.el.on('action-bar-clicked:saving', function(){
      actionBar.saveButtonLadda.ladda( 'start' );
    })
    actionBar.el.on('action-bar-clicked:saved', function(){
      actionBar.stopLadda();
      actionBar.setMode('view');
    })
  }

  ActionBar.prototype.stopLadda = function() {
    console.log("ActionBar: stopLadda");
    this.saveButtonLadda.ladda( 'stop' );
  }

  ActionBar.prototype.barState = function(el, state) {
    console.log("ActionBar: barState");
    this.el.find(el + ' button').attr("disabled", state);
  }

  ActionBar.prototype.setMode = function(mode) {
    console.log("ActionBar: setMode");
    switch(mode){
      case "view":
        this.barState('.cancel-button', "disabled");
        $('.action-bar-template').removeClass('edit-actions').addClass('view-actions');
        break;
      case "edit":
        this.barState('.cancel-button', false);
        $('.action-bar-template').removeClass('view-actions').addClass('edit-actions');
        break;
    }
  }

  return ActionBar;

}());

window.ActionBar = ActionBar;
