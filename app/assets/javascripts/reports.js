$(document).ready(function() {

  $("#save-search form input").keyup(function(e) {
    if (e.keyCode === 13) {
      $("#save-search-button").trigger("click");
    }
  });

  // defined inline on HTML page
  if (typeof C2_SEARCH_QUERY !== "undefined") {
    $("#save-search-query").text(C2_SEARCH_QUERY.humanized);
  }
  $("#save-search form").on("submit", function(e) {
    e.preventDefault();
  });
  $("#save-search-button").click(function() {
    var btn = $(this);
    var savedSearchForm = $("#save-search form");

    // clear any errors and start fresh
    savedSearchForm.find('.form-alert').remove();

    // must have real submit button to trigger HTML5 form validation,
    // but our visible button is outside the <form>.
    // So, we use an invisible button to leverage the browser's validation.
    // See http://stackoverflow.com/questions/16707743/html5-required-validation-not-working
    $("#save-search-submit").click();

    if (typeof savedSearchForm[0].checkValidity === "function" && !savedSearchForm[0].checkValidity()) {
      return;
    }

    var savedSearchName = savedSearchForm.find("[name='saved-search-name']");
    if (!savedSearchName.val()) {
      return;
    }

    // validation ok -- fire the XHR
    savedSearchForm.find('input').prop("disabled", true);
    btn.prop("disabled", true);
    $.post("/reports.json", {
      query: JSON.stringify(C2_SEARCH_QUERY),
      name: savedSearchName.val()
    })
    .fail(function(payload) {
      savedSearchForm.append($('<div class="form-alert alert alert-danger">Something went wrong! Please try again or <a href="/feedback">contact your administrator</a>.</div>'));
    })
    .done(function(payload) {
      var successAlert = $('<div class="alert alert-success"><button type="button" class="close" data-dismiss="alert">x</button>Saved as report <strong>'+savedSearchName.val()+'</strong>!</div>');
      $("#query-links").after(successAlert);
      $("#save-search").modal('hide');
      $(".alert-success").fadeTo(2000, 500).slideUp(500, function() { $(".alert-success").alert('close'); });
    })
    .always(function(payload) {
      savedSearchForm.find('input').prop("disabled", false);
      btn.prop("disabled", false);
    });

  });

});
