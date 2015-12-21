$(document).ready(function() {
  $(".m-search-ui button.search").click(function() {
    var btn = $(this);
    var termsInput = $('.search-terms');
    var form = btn.parent().find('form');
    form.append(termsInput.clone());
    form.submit();
    termsInput.prop("disabled", true);
    btn.prop("disabled", true);
  });
  $(".search-terms").keyup(function(e) {
    if (e.keyCode === 13) {
      $(".m-search-ui button.search").trigger("click");
    }
  });
});
