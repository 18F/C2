var details = details || {
  blastOff: function(){
    this.states();
    this.presenters();
    this.data();
  },
  states: function(){
    var editStateController = new EditStateController('#mode-parent');
  },
  presenters: function(){
    var notificationBar = new ActionBar('.action-bar-status');
    var actionBar = new ActionBar('.action-bar-wrapper');
  },
  data: function(){

  }
};

$(document).ready(function(){
  details.blastOff();
});
