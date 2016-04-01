var detailsApp = detailsApp || {};

detailsApp.blastOff = function(){
  this.setupStatusToggle();
  this.setupRequestDetailsToggle();
}

detailsApp.data = {}

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

$(document).ready(function(){
  detailsApp.blastOff();
});
