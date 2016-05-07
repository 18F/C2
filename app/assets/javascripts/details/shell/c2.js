var C2;
C2 = (function() {
  
  function C2(){
    this.config = {
      editMode:       '#mode-parent',
      formState:      '#request-details-card',
      detailsForm:    '#request-details-card',
      detailsSave:    '#request-details-card',
      attachmentCard: '.card-for-attachments',
      actionBar:      '.action-bar-wrapper'
    }
    this._blastOff();
  }

  C2.prototype._blastOff = function(){
    this._setupStates();
    this._setupViews();
    this._setupData();
    this._setupEvents();
  }

  C2.prototype._setupData = function(){
    var config = this.config;
  }

  C2.prototype._setupStates = function(){
    var config = this.config;
    this.editMode = new EditStateController(config.editMode);
  }
  
  C2.prototype._setupViews = function(){
    var config = this.config;
    this.attachmentCardController = new AttachmentCardController(config.attachmentCard);
    this.actionBar = new ActionBar(config.actionBar);
  }

  C2.prototype._setupEvents = function(){
  }

  return C2;

}());

window.C2 = C2;
