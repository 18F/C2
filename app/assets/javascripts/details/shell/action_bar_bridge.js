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
      updateView:     '#mode-parent'
    }
    this._overrideTestConfig(config);
    this._blastOff();
  }

  ActionBarBridge.prototype._blastOff = function(){
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
    this.config = config;
  }

  ActionBarBridge.prototype._setupEvents = function(){
    this._setupActionBar();
    this._setupSaveModal();
    this._setupFormSubmitModal();
  }

  /* Action Bar */

  ActionBarBridge.prototype._setupActionBar = function(){
    var self = this;
    this.actionBar.el.on("action-bar-clicked:cancel", function(){
      self.editMode.el.trigger('details:cancelled');
    });
    this.actionBar.el.on("action-bar-clicked:save", function(){
      self.notification.clearAll();
    });
    this.actionBar.el.on("action-bar-clicked:edit", function(){
      self.setEditMode();
    });
  }

  ActionBarBridge.prototype.setEditMode = function(){
    this.editMode.el.trigger('details:edit-mode');
  }

  ActionBarBridge.prototype.enableModalButtons = function(){
    this.modals.el.find('button').attr('disabled', false).css('opacity', 1);
  }

  ActionBarBridge.prototype.disableModalButtons = function(){
    this.modals.el.find('button').attr('disabled', 'disabled').css('opacity', 0.5);
  }

  ActionBarBridge.prototype._setupSaveModal = function(){
    var self = this;
    this.modals.el.on("save_confirm-modal:confirm reapproval_confirm-modal:confirm", function(event, item){
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
    var self = this,
      events = "attachment_confirm-modal:confirm observer_confirm-modal:confirm";
    this.modals.el.on(events, function(event, item, sourceEl){
      self._submitAndClose(sourceEl);
    });
  }

  ActionBarBridge.prototype._submitAndClose = function(sourceEl){
    var self = this;
    var url = $(sourceEl).data('delete-url');
    $.ajax({
      url: url,
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      type: 'POST',
      data: {
        _method: "delete"
      }
    });
    self._closeModal();
  }

  ActionBarBridge.prototype._closeModal = function(){
    this.modals.el.trigger("modal:close");
    this.actionBar.stopLadda();
  }
  /* End Action Bar */


  return ActionBarBridge;

}());

window.ActionBarBridge = ActionBarBridge;
