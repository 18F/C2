var C2;
C2 = (function() {
  
  function C2(option = {}){
    this._setupConfig(option);
    this._blastOff();
    this._events();
  }

  C2.prototype._blastOff = function(){
    this._setupStates();
    this._setupViews();
    this._setupData();
  }

  C2.prototype._setupConfig = function(config){
    this.config = {
      editMode:       config.editMode         || '#mode-parent',
      formState:      config.requestDetails   || '#request-details-card',
      detailsForm:    config.requestDetails   || '#request-details-card',
      detailsSave:    config.requestDetails   || '#request-details-card',
      attachmentCard: config.attachmentCard   || '.card-for-attachments',
      actionBar:      config.actionBar        || '.action-bar-wrapper'
    }
  }

  C2.prototype._setupData = function(){
    var config = this.config;
    this.detailsSave = new DetailsSave(config.detailsSave);
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

  C2.prototype._events = function(){
    this._checkFieldChange();
    this._actionBarSave();
    this._actionBarState();
  }
  
  C2.prototype._checkFieldChange = function(){
    var formChanged = true;
    var editMode = this.editMode;
    this.detailsRequestForm.el.on('form:changed', function(){
      if (formChanged) {
        editMode.stateTo('edit');
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

  C2.prototype._actionBarSave = function(){
    var detailsSaveEl = this.detailsSave.el;
    var actionBar = this.actionBar.el;
    actionBar.on("action-bar-clicked:save", function(){
      actionBar.trigger("action-bar-clicked:saved");
      detailsSaveEl.trigger("details-form:save");
    });
  }

  return C2;

}());

window.C2 = C2;
