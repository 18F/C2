var C2;
C2 = (function() {
  
  function C2(option = {}){
    this._setupConfig(option);
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    this._setupStates();
    this._setupViews();
    this._setupData();
    this._setupEvents();
  }

  C2.prototype._setupEvents = function(){
    this._checkFieldChange();
    this._actionBarSave();
    this._actionBarState();
  }
  
  C2.prototype._setupConfig = function(co){
    opt = {};
    opt.editMode        = co.editMode       ? co.editMode       : '#mode-parent';
    opt.formState       = co.requestDetails ? co.requestDetails : '#request-details-card';
    opt.detailsForm     = co.requestDetails ? co.requestDetails : '#request-details-card';
    opt.detailsSave     = co.requestDetails ? co.requestDetails : '#request-details-card';
    opt.attachmentCard  = co.attachmentCard ? co.attachmentCard : '.card-for-attachments';
    opt.actionBar       = co.actionBar      ? co.actionBar      : '.action-bar-wrapper';
    this.config = opt;
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
