$(document).ready(function() {
  $(".m-search-ui button.search").click(function() {
    var btn = $(this);
    var termsInput = $('.search-terms');
    var form = btn.parent().find('form');
    form.append(termsInput.clone());
    termsInput.prop("disabled", true);
    btn.prop("disabled", true);
    form.find('input').prop("disabled", true);
    form.find('select').prop("disabled", true);
    form.find('button').prop("disabled", true);
    form.submit();
  });
  $(".search-terms").keyup(function(e) {
    if (e.keyCode === 13) {
      $(".m-search-ui button.search").trigger("click");
    }
  });
});
