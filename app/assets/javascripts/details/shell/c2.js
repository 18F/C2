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
    this._setupActionBar();
    this._triggerEditToggle();
  }
  
  C2.prototype._triggerEditToggle = function(){
    var self = this;
    this.detailsRequestForm.el.on('edit-toggle:trigger', function(){
      console.log('self.editMode.getState(): ', self.editMode.getState());
      if(!self.editMode.getState()){
        self.detailsEditMode();
      } else {
        self.detailsView();
      }
    });
  }

  C2.prototype._checkFieldChange = function(){
    var self = this;
    this.detailsRequestForm.el.on('form:changed', function(){
      if(self.undoCheck.hasChanged()){
        self.editMode.el.trigger('edit-mode:has-changed');
      } else {
        self.editMode.el.trigger('edit-mode:not-changed');
      }
    });
  }

  C2.prototype._setupActionBar = function(){
    var self = this;
    this.actionBar.el.on("action-bar-clicked:cancel", function(){
      self.detailsView();
    });
    this.actionBar.el.on("action-bar-clicked:save", function(){
      self.detailsSaved();
    });
    this.editMode.el.on('edit-mode:has-changed', function(){
      self.actionBar.editMode();
    });
    this.editMode.el.on('edit-mode:not-changed', function(){
      self.actionBar.viewMode();
    });
  }

  C2.prototype.detailsCancelled = function(){
    this.editMode.stateTo('view');
    this.undoCheck.el.trigger("undo-check:cancel");
    this.actionBar.viewMode();
    this.actionBar.cancelDisable();
    this.undoCheck.viewed = true;
  }
  
  C2.prototype.detailsSaved = function(){
    this.undoCheck.el.trigger("undo-check:save");
    this.actionBar.el.trigger("action-bar-clicked:saved");
    this.detailsSave.el.trigger("details-form:save");
  }
  
  C2.prototype.detailsEditMode = function(){
    this.detailsRequestForm.el.trigger('form:changed');
    this.actionBar.cancelActive();
    this.editMode.stateTo('edit');
    this.detailsRequestForm.toggleButtonText('Cancel');
  }

  C2.prototype.detailsView = function(){
    this.actionBar.cancelDisable();
    this.editMode.stateTo('view');
    this.undoCheck.el.trigger("undo-check:cancel");
    this.actionBar.viewMode();
    this.detailsRequestForm.toggleButtonText('Edit');
    this.undoCheck.viewed = true;
  }

  return C2;

}());

window.C2 = C2;
