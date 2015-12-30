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

  // defined inline on HTML page
  if (typeof C2searchQuery != "undefined") {
    $("#save-search-query").text(C2searchQuery.humanized);
  }
  $("#save-search form").on("submit", function(e) {
    e.preventDefault();
  });
  $("#save-search form input").keyup(function(e) {
    if (e.keyCode == 13) {
      $("#save-search-button").trigger("click");
    }
  });
  $("#save-search-button").click(function() {
    var btn = $(this);
    var form = $("#save-search form");

    // clear any errors and start fresh
    form.find('.form-alert').remove();

    // must have real submit button to trigger HTML5 form validation,
    // but our visible button is outside the <form>.
    // So, we use an invisible button to leverage the browser's validation.
    // See http://stackoverflow.com/questions/16707743/html5-required-validation-not-working
    $("#save-search-submit").click();

    if (typeof form[0].checkValidity == "function" && !form[0].checkValidity()) {
      return;
    }

    var savedSearchName = form.find("[name='saved-search-name']");
    if (!savedSearchName.val()) {
      return;
    }

    // validation ok -- fire the XHR
    form.find('input').prop("disabled", true);
    btn.prop("disabled", true);
    $.post("/reports.json", {
      query: JSON.stringify(C2searchQuery),
      name: savedSearchName.val()
    })
    .fail(function(payload) {
      form.append($('<div class="form-alert alert alert-danger">Something went wrong! Please try again or contact your administrator.</div>'));
    })
    .done(function(payload) {
      var successAlert = $('<div class="alert alert-success"><button type="button" class="close" data-dismiss="alert">x</button>Saved as report <strong>'+savedSearchName.val()+'</strong>!</div>');
      $("#query-links").after(successAlert);
      $("#save-search").modal('hide');
      $(".alert-success").fadeTo(2000, 500).slideUp(500, function() { $(".alert-success").alert('close'); });
    })
    .always(function(payload) {
      form.find('input').prop("disabled", false);
      btn.prop("disabled", false);
    });

  });

});
