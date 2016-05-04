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
  
  return C2;

})();

window.C2 = C2;
