var ActionBar;

ActionBar = (function() {
  function ActionBar(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ActionBar.prototype._setup = function() {
    this._event();
    this.setMode('view');
    this.checkIfFullScreen();
  };

  ActionBar.prototype._event = function() {
    var self = this;
    this.saveButton = this.el.find( '.save-button button' );
    this.saveButton.ladda( 'bind' );
    this.saveButtonLadda = this.saveButton.ladda();
    this._setupActionBarClicked('save');
    this._setupActionBarClicked('cancel');
    this._setupActionBarClicked('edit');
    this._saveTriggered();
    
    $(window).smartresize(function(){
      self.checkIfFullScreen();
    });

  };

  ActionBar.prototype.checkIfFullScreen = function() {
    if(screen.height < window.innerHeight + 200){
      $("body").addClass('near-fullscreen');
    } else {
      $("body").removeClass('near-fullscreen');
    }
  }

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
      actionBar.stopLadda();
      actionBar.setMode('view');
    })
  }

  ActionBar.prototype.stopLadda = function() {
    this.saveButtonLadda.ladda( 'stop' );
  }

  ActionBar.prototype.barState = function(el, state) {
    this.el.find(el + ' button').attr("disabled", state);
  }

  ActionBar.prototype.setMode = function(mode) {
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
