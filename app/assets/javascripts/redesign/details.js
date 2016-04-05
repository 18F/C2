"use strict";

var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
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
  formValue: {}
}

detailsApp.setupData = function(){
  this.saveTemplateDefault();
  this.generateCardObjects();
};

detailsApp.setupEvents = function(){
  var self = this;
  $('input, textarea, select, radio').on('change, keypress, blur, focus, keyup', function(e){
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
  var formAction = $form.attr('action');
  var objectDiff = this.checkObjectDifference(formAction);
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
  $('#request-actions').addClass('edit-mode');
};

detailsApp.defaultActionBar = function(e){
  $('#request-actions').removeClass('edit-mode');
};


detailsApp.generateCardObjects = function(){
  var self = this;
  $('.card form').each(function(i, parentItem){
    var formNameKey = $(parentItem).attr('action');
    var formNameObject = {};
    var $inputFields = $(parentItem).find('textarea, input, select, radio');

    $inputFields.each(function(j, childItem){
      var nameKey = $(childItem).attr('name');
      formNameObject[nameKey] = $(childItem).val();
    });

    var deepObjectCopy = jQuery.extend(true, {}, formNameObject);
    self.data.formValue[formNameKey] = deepObjectCopy;
  });
  console.log(self.data.formValue);
}

detailsApp.checkObjectDifference = function(formAction){
  return objectDiff.diff(detailsApp.data.formValue[formAction], detailsApp.getCardObject(formAction));
}

detailsApp.getCardObject = function(actionValue){
  var selector = '[action="'+ actionValue +'"]';
  var formNameObject = {};
  var $inputFields = $(selector).find('textarea, input, select, radio');

  $inputFields.each(function(j, childItem){
    var nameKey = $(childItem).attr('name');
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
