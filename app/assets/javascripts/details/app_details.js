var DetailsApp = function (){
  var mode = $('#mode-parent');

  var stateEdit = new EditStateController(mode);
  var actionBar = new ActionBar('.action-bar-wrapper');
  
  return function(){
    this.mode = mode;
    this.state = {
      edit: stateEdit
    }
    this.views = {
      actionBar: actionBar
    }
    
    console.log('detailsApp init');
    
    return this;
  }()
}

var detailsApp;

$(document).ready(function(){
  detailsApp = new DetailsApp();
})


// var notificationBar = new ActionBar('.action-bar-status');

