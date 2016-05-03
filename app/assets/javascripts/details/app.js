$(document).ready(function(){
  var attachmentCardController = new AttachmentCardController(".card-for-attachments");
});

var editMode = new EditStateController('#mode-parent');
var formState = new DetailsRequestFormState('#request-details-card');
var actionBar = new ActionBar('#request-actions');

formState.el.on("form:changed", function(){
  var hasChanged = false;
  if(hasChanged){
    editMode.el.on("edit-mode:on", function(){
  } else {
    editMode.el.on("edit-mode:off", function(){
  }
}); 

actionBar.el.on("button:save", function(){
  var editMode = editMode.getState();
  if(editMode){

  } else {
    
  }
});
