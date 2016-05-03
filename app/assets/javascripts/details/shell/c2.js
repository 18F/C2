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
    this.formState.el.on("form:changed", function(){
      var hasChanged = false;
      if(hasChanged){
        this.editMode.el.trigger("edit-mode:on")
      } else {
        this.editMode.el.trigger("edit-mode:off")
      }
    }); 

    this.actionBar.el.on("button:save", function(){
      var editMode = this.editMode.getState();
      if(editMode){
      } else {
      }
    });
  }
  
  return C2;

})();
window.C2 = C2;
