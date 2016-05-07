var C2;
C2 = (function() {
  
  function C2(config){
    config = config || {};
    this.config = {
      editMode:       '#mode-parent',
      formState:      '#request-details-card',
      detailsForm:    '#request-details-card',
      detailsSave:    '#request-details-card',
      attachmentCard: '.card-for-attachments',
      actionBar:      '.action-bar-wrapper'
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
