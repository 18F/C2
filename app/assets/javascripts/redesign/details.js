"use strict";

var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
  this.setupInputFields();
  this.setupEvents();
  this.setupCards();
  this.setupData();
}

detailsApp.templates = {
  "action-bar-wrapper": "",
  "card-for-approvals": "",
  "card-for-activity": "",
  "card-for-request-details": "",
  "card-for-observers": "",
  "action-bar-wrapper": ""
}

detailsApp.data = {
  editMode: {
    "all": false,
    ".card-for-approvals": false,
    ".card-for-activity": false,
    ".card-for-request-details": false,
    ".card-for-observers": false,
    ".action-bar-wrapper": false
  },
  fieldUID: {}
}

detailsApp.setupData = function(){
  this.saveTemplateDefault();
  this.generateCardObjects();
};

detailsApp.setupEvents = function(){
  var self = this;
  $('.card-for-request-details').find('form, input, textarea, select, radio').on('change, keypress, blur, focus, keyup', function(e){
    var el = this;
    self.debounce(self.fieldChanged(e, el), 50);
  });
}

detailsApp.setupCards = function(){
  this.setupStatusToggle();
  this.setupRequestDetailsToggle();
  this.setupCommentController();
  this.setupObserverController();
}

detailsApp.setupInputFields = function(){
  $('form, input, textarea, select, radio, .selectize-input div').each(function(i, item){
    $(item).attr('data-field-guid', detailsApp.guid());
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

detailsApp.saveTemplateDefault = function() {
  var self = this;
  $.each(self.templates, function(key, value){
    detailsApp.templates[key] = $("." + key).html();
  });
  console.log(self.templates);
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

detailsApp.fieldChanged = function(e, el){
  var $form = $(el).closest('form');
  var guidValue = $form.attr('data-field-guid');
  var objectDiff = this.checkObjectDifference(guidValue);
  console.log(objectDiff);
  if (objectDiff["changed"] == "object change"){
    $form.closest('.card').addClass('card-edited');
    this.updateActionBar(e);
  } else {
    $form.closest('.card').removeClass('card-edited');
    this.defaultActionBar(e);
  }
};

detailsApp.updateActionBar = function(e){
  $('.action-bar-wrapper').addClass('edit-mode');
};

detailsApp.defaultActionBar = function(e){
  $('.action-bar-wrapper').removeClass('edit-mode');
};

detailsApp.generateCardObjects = function(){
  var self = this;
  $('.card form').each(function(i, parentItem){
    var formNameKey = $(parentItem).attr('data-field-guid');
    var formNameObject = {};
    var $inputFields = $(parentItem).find('.selectize-input div, textarea, input, select, radio');

    $inputFields.each(function(j, childItem){
      var nameKey = $(childItem).attr('data-field-guid');
      formNameObject[nameKey] = $(childItem).val();
    });

    var deepObjectCopy = jQuery.extend(true, {}, formNameObject);
    self.data.fieldUID[formNameKey] = deepObjectCopy;
  });
  console.log(self.data.fieldUID);
}

detailsApp.checkObjectDifference = function(guidValue){
  return objectDiff.diff(detailsApp.data.fieldUID[guidValue], detailsApp.getCardObject(guidValue));
}

detailsApp.getCardObject = function(guidValue){
  var selector = '.card-for-request-details [data-field-guid="'+ guidValue +'"]';
  var formNameObject = {};
  var $inputFields = $(selector).find('.selectize-input div, textarea, input, select, radio');

  $inputFields.each(function(j, childItem){
    var nameKey = $(childItem).attr('data-field-guid');
    formNameObject[nameKey] = $(childItem).val();
  });

  var deepObjectCopy = jQuery.extend(true, {}, formNameObject);
  
  return deepObjectCopy;
}

detailsApp.setupObserverController = function(){
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
}

detailsApp.setupCommentController = function(){
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
}

detailsApp.guid = function(){
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + '-' + s4() + '-' + s4();
}


detailsApp.debounce = function(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this, args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};

window.detailsApp = detailsApp;

$(document).ready(function(){
  detailsApp.blastOff();
});
