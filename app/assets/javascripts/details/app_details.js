var DetailsApp = function (){
  var mode = $('#mode-parent');
  
  var stateEdit = new EditStateController(mode);
  var actionBar = new ActionBar('.action-bar-wrapper');
  
  mode.on( "edit-mode:on", function( event ) {
    actionBar.editMode();
  });

  mode.on( "edit-mode:off", function( event ) {
    actionBar.viewMode();
  });

  return function(){
    this.stateEdit = stateEdit;
    
    console.log('detailsApp init');

    return this;
  }()
}

var detailsApp;

$(document).ready(function(){
  detailsApp = new DetailsApp();
})


// var notificationBar = new ActionBar('.action-bar-status');

