(function(){

  var details_app = details_app || {};

  details_app.blastOff = function(){
    this.setup_status_toggle();
    this.setup_request_details_toggle();
  }

  details_app.setup_status_toggle = function(){
    $('.status-toggle-all').on('click', function(e){
      e.preventDefault();
      $('.status-contracted').toggleClass('status-expanded');
      if($('.status-contracted').hasClass('status-expanded')){
        $('.status-toggle-all').text('Minimize');
      } else {
        $('.status-toggle-all').text('Show all');
      }
    });
  }

  details_app.setup_request_details_toggle = function() {
    console.log("setting edit button");
    $('.request-detail-edit').on('click', function(e) {
      e.preventDefault();
      $('.detail-form,.detail-element,.detail-value').toggle();
      if($('.detail-value').css('display') == 'none') {
        $('.request-detail-edit').text('View');
      } else {
        $('.request-detail-edit').text('Modify');
      }
    });
  }

  $(document).ready(function(){
    details_app.blastOff();
  });

})();
