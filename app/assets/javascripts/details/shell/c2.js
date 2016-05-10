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
      undoCheck:      '#request-details-card form'
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
    var detailsConfig = this.config.detailsSave;
    var undoConfig = this.config.undoCheck;
    this.detailsSave = new DetailsSave(detailsConfig);
    this.undoCheck = new UndoCheck(undoConfig);
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
    this._triggerEditToggle();
  }
  
  C2.prototype._triggerEditToggle = function(){
    var editMode = this.editMode;
    var detailsForm = this.detailsRequestForm;
    detailsForm.el.on('edit-toggle:trigger', function(){
      console.log('Triggering edit-toggle');
      console.log('editMode.getState(): ', editMode.getState());
      if(!editMode.getState()){
        editMode.stateTo('edit');
      } else {
        editMode.stateTo('view');
      }
    });
  }

  C2.prototype._checkFieldChange = function(){
    var self = this;
    var editMode = this.editMode;
    this.detailsRequestForm.el.on('form:changed', function(){
      console.log('self.undoCheck.hasChanged(): ', self.undoCheck.hasChanged());
      if(self.undoCheck.hasChanged()){
        editMode.el.trigger('edit-mode:has-changed');
      } else {
        editMode.el.trigger('edit-mode:not-changed');
      }
    });
  }

  C2.prototype._actionBarState = function(){
    var editMode = this.editMode.el;
    var actionBar = this.actionBar;
    editMode.on('edit-mode:has-changed', function(){
      actionBar.editMode();
    });
    editMode.on('edit-mode:not-changed', function(){
      actionBar.viewMode();
    });
  }

  C2.prototype._setupActionBarCancel = function(){
    var editMode = this.editMode.el;
    var actionBar = this.actionBar.el;
    var undoCheck = this.undoCheck.el;
    var detailsRequestForm = this.detailsRequestForm;
    actionBar.on("action-bar-clicked:cancel", function(){
      editMode.trigger('edit-mode:off');
      undoCheck.trigger("undo-check:cancel");
      detailsRequestForm._setup();
    });
  }

  C2.prototype._setupActionBarSave = function(){
    var detailsSave = this.detailsSave.el;
    var actionBar = this.actionBar.el;
    var undoCheck = this.undoCheck.el;
    actionBar.on("action-bar-clicked:save", function(){
      undoCheck.trigger("undo-check:save");
      actionBar.trigger("action-bar-clicked:saved");
      detailsSave.trigger("details-form:save");
    });
  }

  return C2;

}());

window.C2 = C2;
