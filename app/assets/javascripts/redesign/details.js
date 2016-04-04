"use strict";

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
  var $editButton = $(".request-detail-edit-button");
  $editButton.on("click", function(e) {
    e.preventDefault();
    $('#edit-request-details,#view-request-details').toggle();
    if($('#view-request-details').css('display') == 'none') {
      $('span', $editButton).text('View');
    } else {
      $('span', $editButton).text('Modify');
    }
    return false;
  });
}

detailsApp.setupDataObject = function($elem) {
  var self = this;
  var cardKeys = $elem.find('[data-card-key]');

  cardKeys.each( function(index, elem) {
    var elemDataKey = $(elem).data('card-key');
    var elemDataKeyArray = elemDataKey.split('-');
    var elemDataValue = $(elem).data('card-value');
    var parent = self.data;

    for (var i = 0; i <= elemDataKeyArray.length - 2; i++) {
      var elKey = elemDataKeyArray[i];
      if(parent[elKey] === undefined){
        parent[elKey] = {};
      }
      parent = parent[elKey];
    }
    parent[elemDataKeyArray[elemDataKeyArray.length-1]] = elemDataValue;
  })
}

detailsApp.updateStaticElements = function($elem) {
  var self = this;
  var cardKeys = $elem.find('div[data-card-key]')
                      .add($elem.find('span[data-card-key]'));

  cardKeys.each(function(index, elem) {
    var $elem = $(elem);
    var newValue = self.lookup($elem.data('card-key'));
    $elem.text(newValue);
    $elem.data('card-value', newValue);
  });
};

// Currently only goes 2 levels deep
detailsApp.lookup = function(elemDataKey) {
  var self = this;
  var elemDataKeyArray = elemDataKey.split("-");
  var parentKey = elemDataKeyArray[0];
  var childKey = elemDataKeyArray[1];
  if (self.data[parentKey] !== undefined) {
    return self.data[parentKey][childKey];
  }
}


$(document).ready(function(){
  detailsApp.blastOff();
});
