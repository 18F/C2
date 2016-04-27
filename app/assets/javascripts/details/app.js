var details = details || {
  blastOff: function(){
    var editStateController = new EditStateController('#mode-parent');
    var notificationBar = new ActionBar('.action-bar-status');
    var actionBar = new ActionBar('.action-bar-wrapper');
  }
};

$(document).ready(function(){
  details.blastOff();
});
