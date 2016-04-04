var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
  this.setupStatusToggle();
  this.setupRequestDetailsToggle();
  this.setupEvents();
}

detailsApp.data = {}

detailsApp.setupEvents = function(){
  $(window).on('scroll', function(e){
    
  })
}

detailsApp.setupStatusToggle = function(){
  $('.status-toggle-all').on('click', function(e){
    e.preventDefault();
    $('.status-contracted').toggleClass('status-expanded');
    if($('.status-contracted').hasClass('status-expanded')){
      $('.status-toggle-all.status-text').text('Minimize');
    } else {
      $('.status-toggle-all.status-text').text('Show all');
    }
  });
}

detailsApp.setupRequestDetailsToggle = function() {
  console.log("setting edit button");
  $('.request-detail-edit').on('click', function(e) {
    e.preventDefault();
    $('.detail-form,.detail-element,.detail-value,.detail-view').toggle();
    if($('.detail-value').css('display') == 'none') {
      $('.request-detail-edit span').text('View');
    } else {
      $('.request-detail-edit span').text('Modify');
    }
  });
}

detailsApp.setupDataObject = function($elem) {
  
  var self = this;
  var cardKeys = $elem.find("[data-card-key]");

  cardKeys.each( function(index, elem) {
    var elemDataKey = $(elem).data('card-key');
    var elemDataKeyArray = elemDataKey.split('-');
    var elemDataValue = $(elem).data('card-value');
    // console.log("Value: " + elemDataValue);
    var parent = self.data;

    for (var i = 0; i <= elemDataKeyArray.length - 2; i++) {
      var elKey = elemDataKeyArray[i];
      if(parent[elKey] == undefined){
        parent[elKey] = {};
      }
      parent = parent[elKey];
    }
    // console.log("Parent: ", elemDataKeyArray[elemDataKeyArray.length-1]);
    parent[elemDataKeyArray[elemDataKeyArray.length-1]] = elemDataValue;
  })
  console.dir(self.data);
}


$(document).ready(function(){
  detailsApp.blastOff();
});
