$(document).ready(function(){
  var attachmentCardController = new AttachmentCardController(".card-for-attachments");
});

var editMode = new EditStateController('#mode-parent');
var formState = new DetailsRequestFormState('#request-details-card');

formState.el.on("form:changed", function(){
  var hasChanged = false;
  if(hasChanged){
    editMode.el.on("edit-mode:on", function(){
  } else {
    editMode.el.on("edit-mode:off", function(){
  }
}); 
