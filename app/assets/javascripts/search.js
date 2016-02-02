$(document).ready(function() {
  $(".m-search-ui button.search").click(function() {
    var btn = $(this);
    var form = $('form.adv-search');
    form.submit();
    // IMPORTANT disable *AFTER* submit
    form.find('fieldset').prop("disabled", true);
    btn.prop("disabled", true);
  });
  $('form.adv-search').on("submit", function(e) {
    var form = $(this);
    var termsInput = $('.search-terms');
    if (termsInput.val().length) {
      var textInput = $('<input type="hidden" name="text">');
      textInput.val(termsInput.val());
      form.append(textInput);
    }
    termsInput.prop("disabled", true);
    return true;
  });
  $(".search-terms").keyup(function(e) {
    if (e.keyCode === 13) {
      $(".m-search-ui button.search").trigger("click");
    }
  });
});
