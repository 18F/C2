"use strict";

var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
  this.setupStatusToggle();
  this.setupRequestDetailsToggle();
  this.setupEvents();
}

detailsApp.data = {}

detailsApp.setupEvents = function(){
  $('input, textarea, select, radio').on('change, keypress', function(e){
    detailsApp.fieldChanged(e);
  });
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

detailsApp.fieldChanged = function(e){
  console.log('Field changed: ', e);
};

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

//AJAX comment functionality
$(document).ready(function(){
  var $comments = $('#comments');
  var current_user = $('div.current_user').html();
  $('form#new_comment').submit(function() {  
      var valuesToSubmit = $(this).serialize();
      var value = $('form#new_comment textarea').val();
      $('form#new_comment textarea').val("");
      $.ajax({
          type: "POST",
          url: $(this).attr('action'), //sumbits it to the given url of the form
          data: valuesToSubmit,
          dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
      }).done(function(json){
          console.log("success", json);
      }).fail(function(json){
        console.log("failed", valuesToSubmit);
      }).always(function(json){
        var comment = "<div class='column medium-12 row status-expanded status-feed-wrapper status-index-0 text-left'><div class='medium-table-row medium-12 status-feed-item status-attachment-block no-margin-bottom'><div class='hide-for-small-only medium-table-cell medium-activity-icon-col text-center status-feed-timeline background-color-column'><div class='dot-circle'></div></div><div class='medium-table-cell medium-auto-column status-feed-content'><div class='title-block'><span class='status-action'>Comment created by " + current_user + "</span><span class='time-from'><span title='Apr 4, 2016 at  3:03pm'>less than a minute ago</span></span></div><div class='item-block'>" + value + "</div></div></div></div>";
        $comments.prepend(comment);
      });
      return false; // prevents normal behaviour
  });
});

$(document).ready(function(){
  var $observers = $('.observer-list');
  var form = '<form class="button_to remove_ajax"><input data-confirm="Are you sure?" type="submit" value="Remove" /></form>'

  $('form#new_observation').submit(function(){
    var valuesToSubmit = $(this).serialize();
    var value = $('form#new_observation :selected').text();
    $observers.append('<li class="observer-list-item">' + value + form + '</li>');
    return false;//prevents default
  });
  
  $(document).on('submit','form.remove_ajax',function(){
    $(this).parent().remove();
    return false;
  });
});

