$(document).ready(function(){

  $('.status-toggle-all').on('click', function(e){
    e.preventDefault();
    $('.status-contracted').toggleClass('status-expanded');
    if($('.status-contracted').hasClass('status-expanded')){
      $('.status-toggle-all').text('Minimize');
    } else {
      $('.status-toggle-all').text('Show all');
    }
  });

});

var details_app = details_app || {};

