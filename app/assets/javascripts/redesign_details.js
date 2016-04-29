$('.status-toggle-all').on('click', function(e){
  e.preventDefaults();
  $('.status-contracted').toggleClass('status-expanded') ;
});
