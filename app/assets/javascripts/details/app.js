var DetailsApp = function (){
  var mode = $('#mode-parent');
  
  var stateEdit = new EditStateController(mode);

  var setup = function(){
    this.mode = mode;
    this.stateEdit = stateEdit;
  }
}
  
$(document).ready(function(){
  detailsApp = new DetailsApp();
})


// var actionBar = new ActionBar('.action-bar-wrapper');
// var notificationBar = new ActionBar('.action-bar-status');

