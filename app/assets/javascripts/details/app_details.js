var DetailsApp = function (){
  var mode = $('#mode-parent');

  var stateEdit = new EditStateController(mode);
  var actionBar = new ActionBar('.action-bar-wrapper');
  
  var blastOff = function(){
    this.mode = mode;
    this.state = {
      edit: stateEdit
    }
    this.views = {
      actionBar: actionBar
    }
    return this;
  }

  return blastOff();
}

var detailsApp;

$(document).ready(function(){
  console.log('detailsApp init');
  detailsApp = new DetailsApp();
})


// var notificationBar = new ActionBar('.action-bar-status');

