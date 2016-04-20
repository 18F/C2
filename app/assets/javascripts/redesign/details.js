"use strict";

var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
  this.setupInputFields();
  this.setupEvents();
  this.setupCards();
  this.setupData();
};

detailsApp.templates = {
  "action-bar-wrapper": "",
  "card-for-approvals": "",
  "card-for-activity": "",
  "card-for-request-details": "",
  "card-for-observers": "",
  "card-for-attachments": ""
};

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
};

detailsApp.setupData = function(){
  this.saveTemplateDefault();
  this.setupFormEl();
  this.generateCardObjects();
};

detailsApp.setupEvents = function(){
  var self = this;
  $("#request-details-card").find("input, textarea, select, radio").on("change keypress blur focus keyup", function(e){
    var el = this;
    self.debounce(self.fieldChanged(e, el), 50);
  });
  $(".save-button a").on("click", function(e){
    e.preventDefault();
    var valid = true;
    if(valid){
      self.postActionSaveHook();
      self.setupFormEl("#request-details-card");
      self.generateCardObjects();
      self.defaultActionBar();
    }
  });
};

detailsApp.setupCards = function(){
  this.setupStatusToggle();
  this.setupRequestDetailsToggle();
  this.setupCommentController();
  this.setupObserverController();
  this.setupAttachmentController();
};

detailsApp.setupInputFields = function(){
  $("form, input, textarea, select, radio").each(function(i, item){
    $(item).attr("data-field-guid", detailsApp.guid());
  });
};

detailsApp.setupStatusToggle = function(){
  if ($(".status-toggle-all")) {
    $(".status-toggle-all").on("click", function (e) {
      e.preventDefault();
      $(".status-contracted").toggleClass("status-expanded");
      $(".status-contract-action,.status-expand-action").toggle();
    });
  }
};

detailsApp.setupFormEl = function(card) {
  this.data.$el = $(card + " form");
}

detailsApp.setupRequestDetailsToggle = function() {
  var $editButton = $(".request-detail-edit-button");
  $editButton.on("click", function(e) {
    e.preventDefault();
    $("#mode-parent").toggleClass("edit-mode").toggleClass("view-mode");
    if( !$("#mode-parent").hasClass("view-mode") ) {
      $("span", $editButton).text("View");
    } else {
      $("span", $editButton).text("Modify");
    }
    return false;
  });
};

detailsApp.saveTemplateDefault = function() {
  var self = this;
  $.each(self.templates, function(key){
    detailsApp.templates[key] = $("." + key).html();
  });
  console.log(self.templates);
};

detailsApp.fieldChanged = function(e, el){
  var $form = $(el).closest("form");
  var guidValue = $form.attr("data-field-guid");
  var objectDiff = this.checkObjectDifference(guidValue);
  console.log(objectDiff);
  this.updateStaticSibling(el);
  if (objectDiff["changed"] === "object change"){
    $form.closest(".card").addClass("card-edited");
    this.updateActionBar(e);
  } else {
    $form.closest(".card").removeClass("card-edited");
    this.defaultActionBar(e);
  }
};

detailsApp.updateStaticSibling = function(el) {
  var value = this.getPrintableValue(el);
  var staticEl = $(el).closest(".detail-wrapper").find(".detail-value");
  $(staticEl).text(value);
};

detailsApp.getPrintableValue = function(el) {
  switch(el.tagName) {
    case "SELECT":
      return $(":selected", el).text();
    case "INPUT":
      if (el.type === "checkbox") {
        return el.checked ? "Yes" : "No";
      } else if (el.type === "text" && el.value.trim() === "") {
        return "-";
      } else {
        return $(el).val();
      }
      break;
    default:
      return $(el).val();
  }
};

detailsApp.postActionSaveHook = function(){
  $(".request-detail-edit-button").click();
  $('#request-details-card [type="submit"]').click();
  this.showNotification('You updates have been saved.');
}

detailsApp.updateActionBar = function(){
  $(".action-bar-wrapper").addClass("edit-actions");
  $(".action-bar-wrapper .save-button a").attr('disabled', false);
};

detailsApp.defaultActionBar = function(){
  $(".action-bar-wrapper .save-button a").attr('disabled', true);
  $(".action-bar-wrapper").removeClass("edit-actions");
};

detailsApp.showNotification = function(message){
  $('.action-bar-status .action-status-value').text(message);
  $('.action-bar-status').fadeIn();
  window.setTimeout(function(){
    $('.action-bar-status').fadeOut();
  }, 3000);
};

detailsApp.reinitObserverRemove = function(){
  var self = this;
  $('form.button_to [type="submit"]').on('click', function(e){
    e.preventDefault();
    var formRemoveButtonGuid = $(this).attr('data-field-guid');
    self.triggerObserverRemove(formRemoveButtonGuid);
  });
};

detailsApp.triggerObserverRemove = function(guid){
  this.loadRemoveConfirmModal(guid);
}

/* 
 * Element clicked should have "data-remove-guid" with the GUID 
 * use GUID to find "data-field-guid" and target parent()
 */
detailsApp.loadRemoveConfirmModal = function(){
  var removeFormGuid = $(this).attr('data-remove-guid');
  $('[data-field-guid="' + removeFormGuid + '"]').parent().remove();
}

detailsApp.deleteObserverRow = function(){
  $(this).data()
}

detailsApp.generateCardObjects = function(){
  var self = this;
  var $el = self.data.$el;
  $el.each(function(i, parentItem){
    var formNameKey = $(parentItem).attr("data-field-guid");
    var formNameObject = {};
    var $inputFields = $(parentItem).find(".selectize-input div, textarea, input, select, radio");

    $inputFields.each(function(j, childItem){
      var nameKey = $(childItem).attr("data-field-guid");
      formNameObject[nameKey] = $(childItem).val();
    });

    var deepObjectCopy = jQuery.extend(true, {}, formNameObject);
    self.data.fieldUID[formNameKey] = deepObjectCopy;
  });
};

detailsApp.checkObjectDifference = function(guidValue){
  return objectDiff.diff(detailsApp.data.fieldUID[guidValue], detailsApp.getCardObject(guidValue));
};

detailsApp.getCardObject = function(guidValue){
  var selector = ".card-for-request-details [data-field-guid='"+ guidValue +"']";
  var formNameObject = {};
  var $inputFields = $(selector).find(".selectize-input div, textarea, input, select, radio");

  $inputFields.each(function(j, childItem){
    var nameKey = $(childItem).attr("data-field-guid");
    formNameObject[nameKey] = $(childItem).val();
  });

  var deepObjectCopy = jQuery.extend(true, {}, formNameObject);
  return deepObjectCopy;
};

detailsApp.setupObserverController = function(newRow){
  var $observers = $(".observer-list");
  $observers.append(newRow);
};

detailsApp.attachmentListener = function(card){
  $("div.card-for-attachments ul.attachment-list").html(card);
}


detailsApp.setupCommentController = function(){
  var $comments = $("#comments");
  var current_user = $("div.current_user").html();
  $("form#new_comment").submit(function() {
      var valuesToSubmit = $(this).serialize();
      var value = $("form#new_comment textarea").val();
      var comment = "<div class='column medium-12 row status-expanded status-feed-wrapper status-index-0 text-left'><div class='medium-table-row medium-12 status-feed-item status-attachment-block no-margin-bottom'><div class='hide-for-small-only medium-table-cell medium-activity-icon-col text-center status-feed-timeline background-color-column'><div class='dot-circle'></div></div><div class='medium-table-cell medium-auto-column status-feed-content'><div class='title-block'><span class='status-action'>Comment created by " + current_user + "</span><span class='time-from'><span title='Apr 4, 2016 at  3:03pm'>less than a minute ago</span></span></div><div class='item-block'>" + value + "</div></div></div></div>";
      $comments.prepend(comment);
      $("form#new_comment textarea").val("");
      $.ajax({
          type: "POST",
          url: $(this).attr("action"), //sumbits it to the given url of the form
          data: valuesToSubmit,
          dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
      }).done(function(json){
          console.log("success", json);
      }).fail(function(json){
        console.log("failed", valuesToSubmit);
      }).always(function(json){
      });
      return false; // prevents normal behaviour
  });
};

detailsApp.guid = function(){
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + "-" + s4() + "-" + s4();
};


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
