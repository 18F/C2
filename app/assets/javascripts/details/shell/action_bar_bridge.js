var ActionBarBridge;
ActionBarBridge = (function() {

  function ActionBarBridge(c2, config){
    this.c2 = c2;
    config = config || {};
    this.config = {
      actionBar:      '#action-bar-wrapper',
      detailsSave:    '#request-details-card',
      notifications:  '#action-bar-status',
      editMode:       '#mode-parent',
      modalCard:      '#modal-wrapper',
      updateView:     '#mode-parent',
    }
    this._overrideTestConfig(config);
    this._blastOff();
  }

  ActionBarBridge.prototype._blastOff = function(){
    console.log('ActionBarBridge: _blastOff');
    var config = this.config;


    // Data
    this.detailsSave = this.c2.detailsSave;
    this.updateView = this.c2.updateView;

    // State
    this.editMode = this.c2.editMode;

    // Views
    this.modals = this.c2.modals;
    this.actionBar = this.c2.actionBar;
    this.notification = this.c2.notification;
    this._setupEvents();
  }

  ActionBarBridge.prototype._overrideTestConfig = function(config){
    console.log('ActionBarBridge: _overrideTestConfig');
    var opt = this.config;
    $.each(opt, function(key, item){
      if(config[key]){
        opt[key] = config[key];
      }
    });
    this.config = opt;
  }

  ActionBarBridge.prototype._setupEvents = function(){
    console.log('ActionBarBridge: _setupEvents');
    this._setupActionBar();
    this._setupSaveModal();
    this._setupFormSubmitModal();
  }

  /* Action Bar */

  ActionBarBridge.prototype._setupActionBar = function(){
    console.log('ActionBarBridge: _setupActionBar');
    var self = this;
    this.actionBar.el.on("action-bar-clicked:cancel", function(){
      self.editMode.el.trigger('details:cancelled');
    });
    this.actionBar.el.on("action-bar-clicked:save", function(){
      self.notification.clearAll();
    });
    this.actionBar.el.on("action-bar-clicked:edit", function(){
      self.editMode.el.trigger('details:edit-mode');
    });
  }

  ActionBarBridge.prototype.enableModalButtons = function(){
    console.log('ActionBarBridge: enableModalButtons');
    this.modals.el.find('button').attr('disabled', false).css('opacity', 1);
  }

  ActionBarBridge.prototype.disableModalButtons = function(){
    console.log('ActionBarBridge: disableModalButtons');
    this.modals.el.find('button').attr('disabled', 'disabled').css('opacity', 0.5);
  }

  ActionBarBridge.prototype._setupSaveModal = function(){
    console.log('ActionBarBridge: _setupSaveModal');
    var self = this;
    this.modals.el.on("save_confirm-modal:confirm", function(event, item){
      var l = $(item).ladda();
      l.ladda( 'start' );
      self.disableModalButtons();
      self.actionBar.el.trigger("action-bar-clicked:saving");
      self.detailsSave.el.trigger("details-form:save");
    });
    this.modals.el.on("save_confirm-modal:cancel", function(event, item){
      self._closeModal();
    });
    this.modals.el.on("modal:cancel", function(){
      self.actionBar.stopLadda();
    });
  }

  ActionBarBridge.prototype._setupFormSubmitModal = function(){
    console.log('ActionBarBridge: _setupFormSubmitModal');
    var self = this,
      events = "attachment_confirm-modal:confirm observer_confirm-modal:confirm";
    this.modals.el.on(events, function(event, item, sourceEl){
      self._submitAndClose(sourceEl);
    });
  }

  ActionBarBridge.prototype._submitAndClose = function(sourceEl){
    console.log('ActionBarBridge: _submitAndClose');
    var self = this;
    $(sourceEl).parent().submit();
    self._closeModal();
  }

  ActionBarBridge.prototype._closeModal = function(){
    console.log('ActionBarBridge: _closeModal');
    this.modals.el.trigger("modal:close");
    this.actionBar.stopLadda();
  }
  /* End Action Bar */


  return ActionBarBridge;

}());

window.ActionBarBridge = ActionBarBridge;

