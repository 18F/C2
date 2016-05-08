var C2;
C2 = (function() {
  
  function C2(config){
    config = config || {};
    this.config = {
      actionBar:      '.action-bar-wrapper',
      attachmentCard: '.card-for-attachments',
      detailsForm:    '#request-details-card',
      detailsSave:    '#request-details-card',
      editMode:       '#mode-parent',
      formState:      '#request-details-card',
      undoCheck:      '#request-details-card form',
    }
    this._overrideTestConfig(config);
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    this._setupStates();
    this._setupViews();
    this._setupData();
    this._setupEvents();
  }

  C2.prototype._overrideTestConfig = function(config){
    var opt = this.config;
    $.each(opt, function(key, item){
      if(config[key]){
        opt[key] = config[key];
      }
    });
    this.config = opt;
  }

  C2.prototype._setupData = function(){
    var config = this.config;
    this.detailsSave = new DetailsSave(config.detailsSave);
    this.undoCheck = new UndoCheck(config.undoCheck);
  }

  C2.prototype._setupStates = function(){
    var config = this.config;
    this.editMode = new EditStateController(config.editMode);
    this.formState = new DetailsRequestFormState(config.formState);
  }
  
  C2.prototype._setupViews = function(){
    var config = this.config;
    this.detailsRequestForm = new DetailsRequestForm(config.detailsForm);
    this.attachmentCardController = new AttachmentCardController(config.attachmentCard);
    this.actionBar = new ActionBar(config.actionBar);
  }

  C2.prototype._setupEvents = function(){
    this._checkFieldChange();
    this._setupActionBarSave();
    this._setupActionBarCancel();
    this._actionBarState();
  }
  
  C2.prototype._checkFieldChange = function(){
    var self = this;
    var editMode = this.editMode;
    this.detailsRequestForm.el.on('form:changed', function(){
      if (self.undoCheck.hasChanged()) {
        editMode.el.trigger('edit-mode:on');
      } else {
        editMode.el.trigger('edit-mode:off');
      }
    });
  }

  C2.prototype._actionBarState = function(){
    var editModeEl = this.editMode.el;
    var actionBar = this.actionBar;
    editModeEl.on('edit-mode:on', function(){
      actionBar.editMode();
    });
    editModeEl.on('edit-mode:off', function(){
      actionBar.viewMode();
    });
  }

  C2.prototype._setupActionBarCancel = function(){
    var editModeEl = this.editMode.el;
    var actionBar = this.actionBar.el;
    var undoCheck = this.undoCheck.el;
    actionBar.on("action-bar-clicked:cancel", function(){
      editModeEl.trigger('edit-mode:off');
      undoCheck.trigger("undo-check:cancel");
    });
  }

  C2.prototype._setupActionBarSave = function(){
    var detailsSaveEl = this.detailsSave.el;
    var actionBar = this.actionBar.el;
    var undoCheck = this.undoCheck.el;
    actionBar.on("action-bar-clicked:save", function(){
      undoCheck.trigger("undo-check:save");
      actionBar.trigger("action-bar-clicked:saved");
      detailsSaveEl.trigger("details-form:save");
    });
  }

  return C2;

}());

window.C2 = C2;
