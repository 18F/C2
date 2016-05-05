var C2;
C2 = (function() {
  
  function C2(){
    this._blastOff();
    this._events();
  }

  C2.prototype._blastOff = function(){
    this._setupConfig();
    this._setupStates();
    this._setupViews();
  }

  C2.prototype._setupConfig = function(){
    var test = window.test || {};
    this.config = {
      editMode:       test.editMode         || '#mode-parent',
      formState:      test.formState        || '#request-details-card',
      attachmentCard: test.attachmentCard   || '.card-for-attachments',
      actionBar:      test.actionBar        || '.action-bar-wrapper'
    }
  }

  C2.prototype._setupStates = function(){
    var config = this.config;
    this.editMode = new EditStateController(config.editMode);
    this.formState = new DetailsRequestFormState(config.formState);
  }
  
  C2.prototype._setupViews = function(){
    var config = this.config;
    this.attachmentCardController = new AttachmentCardController(config.attachmentCard);
    this.actionBar = new ActionBar(config.actionBar);
  }

  C2.prototype._events = function(){
    this._actionBarSave();
  }
  
  C2.prototype._actionBarSave = function(){
    var actionBar = this.actionBar.el;
    actionBar.on("actionBarClicked:save", function(){
      var editMode = self.editMode.getState();
      if(editMode){
        actionBar.trigger("actionBarClicked:saved");
      } else {
      }
    });
  }

  return C2;

}());

window.C2 = C2;
