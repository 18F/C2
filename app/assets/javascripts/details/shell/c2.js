var C2;
C2 = (function() {
  
  function C2(){
    this._blastOff();
    this._events();
  }

  C2.prototype._blastOff = function(){
    this.attachmentCardController = new AttachmentCardController(".card-for-attachments");
    this.editMode = new EditStateController('#mode-parent');
    this.formState = new DetailsRequestFormState('#request-details-card');
    this.actionBar = new ActionBar('.action-bar-wrapper');
  }

  C2.prototype._events = function(){
    this._formChanges();
    this._actionBarSave();
  }

  C2.prototype._actionBarSave = function(){
    var self = this;
    this.actionBar.el.on("actionBarClicked:save", function(){
      var editMode = self.editMode.getState();
      if(editMode){
        self.saveRequestDetailsChanges();
      }
    });
  }

  C2.prototype.saveRequestDetailsChanges = function(){
    this.editMode.el.trigger("edit-mode:off")
  }

  C2.prototype._formChanges = function(){
    var self = this,
        editMode = this.editMode.el,
        hasChanged;
    this.formState.el.on("form:changed", function(){
      hasChanged = false;
      if(hasChanged){
        editMode.trigger("edit-mode:on")
      } else {
        editMode.trigger("edit-mode:off")
      }
    }); 
  }
  
  return C2;

})();

window.C2 = C2;
