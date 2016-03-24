$(document).ready(function() {

  /*************************************************************************************************/
  /* ** Search Form ** */

  var advOptionsVisible = function() {
    return $("fieldset.adv").is(":visible");
  };

  var FADE_SPEED = 200;

  // manage the basic search input button via the search-terms field
  var searchTerms = $(".m-search-ui .search-terms");
  var buttonToggler = function() {
    if (searchTerms.val().length == 0) {
      $("#search-button").hide();
      $(".m-search-ui .input-group-addon.magnifier").fadeIn(FADE_SPEED);
    }
    else {
      if (!advOptionsVisible()) {
        $("#adv-options").fadeIn(FADE_SPEED);
      }
      $(".m-search-ui .input-group-addon.magnifier").hide();
      $("#search-button").fadeIn(FADE_SPEED);
    }
  };

  var showAdvOptions = function() {
    $("fieldset.adv").fadeIn(FADE_SPEED);
    $("fieldset.controls").show();
    $("#adv-options").hide();
    $("#search-button").hide();
    $(".m-search-ui .input-group-addon.magnifier").show();
    $(".m-search-ui").addClass("expanded");
  };
  var hideAdvOptions = function() {
    $("fieldset.adv").hide();
    $("fieldset.controls").hide();
    $("#adv-options").fadeIn(FADE_SPEED);
    buttonToggler();
    $(".m-search-ui").removeClass("expanded");
  };
  $("a.adv-options").click(function(e) {
    showAdvOptions();
    return false;
  });

  $(".adv-controls .closer").click(function() {
    hideAdvOptions();
    return false;
  });

  // initial visibility
  // open the Adv Search UI immediately if param set 
  if (typeof C2_SEARCH_UI_OPEN != "undefined" && C2_SEARCH_UI_OPEN === true ) {
    showAdvOptions();
  }
  else {
    hideAdvOptions();
    buttonToggler();
  }

  // listen for change
  searchTerms.keyup(function(e) {
    if (!advOptionsVisible()) {
      buttonToggler();
    }
  });

  searchTerms.focusin(function() {
    if (!advOptionsVisible()) {
      $("#adv-options").fadeIn(FADE_SPEED);
    }
  });

  searchTerms.focusout(function(e) {
    if (searchTerms.val().length == 0) {
      // use timeout to workaround click on adv-options button,
      // so that the click event can also fire.
      window.setTimeout(function() { $("#adv-options").hide(FADE_SPEED); }, 200);
    }
  });

  // disable the form when we submit it
  $(".m-search-ui button.search").click(function() {
    var btn = $(this);
    var searchForm = $('form.search');
    searchForm.submit();
    // IMPORTANT disable *AFTER* submit
    searchForm.find('fieldset').prop("disabled", true);
    btn.prop("disabled", true);
  });

  // fetch search total for preview count
  var updatePreviewCount = function() {
    var countEl = $(".results-count-preview .count");
    var randN = Math.floor((Math.random() * 10) + 1);
    countEl.html(randN);

  };

  // if any adv search form inputs change, fetch new preview total
  // the 'keyup' listener handles text input immediately (change waits for focus change)
  $('form.search :input').keyup(function(e) {
    var el = $(e.target);
    //console.log('adv search keyup: ', el[0].name);
    updatePreviewCount();
  });
  // the 'onchange' listener handles select/checkbox/radio immediately
  $('form.search :input').change(function(e) {
    var el = $(e.target);
    //console.log('adv search change: ', el[0].name);
    updatePreviewCount();
  });

  // ENTER key submits form
  var clickOnEnter = function(e, cls) {
    if (e.keyCode === 13) {
      $(cls).trigger("click");
    }
  };
  $(".search-terms").keyup(function(e) {
    clickOnEnter(e, ".m-search-ui button.search");
  });

  /******************************************************************************************************/
  /* *** setup Save as Report *** */
  $("#save-search form input").keyup(function(e) {
    clickOnEnter(e, "#save-search-button");
  });

  // defined inline on HTML page
  if (typeof C2_SEARCH_QUERY != "undefined") {
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

    if (typeof savedSearchForm[0].checkValidity == "function" && !savedSearchForm[0].checkValidity()) {
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
