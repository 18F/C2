$(document).ready(function() {

  var searchUI = $(".m-search-ui");
  var advOptsFieldset = $("fieldset.adv");
  var advOptsControlsFieldset = $("fieldset.controls");
  var searchTerms = $(".m-search-ui .search-terms");
  var searchButton = $("#search-button");
  var searchMagGlass = $(".m-search-ui .input-group-addon.magnifier");
  var advOptsButton = $("#adv-options");
  var advOptsToggler = $("a.adv-options");
  var advOptsCloser = $(".adv-controls .closer");
  var allSearchButtons = $(".m-search-ui button.search");
  var searchForm = $("form.search");
  var countEl = $(".results-count-preview .count");
  var advOptsResetter = $("a.resetter");

  var advOptionsVisible = function() {
    return advOptsFieldset.is(":visible");
  };

  var searchTermsHasFocus = function() {
    return searchTerms.is(":focus");
  };

  var FADE_SPEED = 200;

  var showAdvOptsButton = function() {
    advOptsButton.fadeIn(FADE_SPEED);
    searchTerms.addClass('search-terms-adv-show');
  };

  var hideAdvOptsButton = function() {
    advOptsButton.hide();
    searchTerms.removeClass('search-terms-adv-show');
  };

  var buttonToggler = function() {
    if (searchTerms && (!searchTerms.val() || searchTerms.val().length == 0)) {
      searchButton.hide();
      searchMagGlass.fadeIn(FADE_SPEED);
    }
    else {
      if (!advOptionsVisible()) {
        showAdvOptsButton();
      }
      searchMagGlass.hide();
      searchButton.fadeIn(FADE_SPEED);
    }
  };

  var showAdvOptions = function() {
    advOptsFieldset.fadeIn(FADE_SPEED);
    advOptsControlsFieldset.show();
    hideAdvOptsButton();
    searchButton.hide();
    searchMagGlass.show();
    searchUI.addClass("expanded");
  };
  var hideAdvOptions = function() {
    advOptsFieldset.hide();
    advOptsControlsFieldset.hide();
    showAdvOptsButton();
    buttonToggler();
    searchUI.removeClass("expanded");
  };
  advOptsToggler.click(function(e) {
    showAdvOptions();
    return false;
  });

  advOptsCloser.click(function() {
    hideAdvOptions();
    return false;
  });

  if (typeof C2_SEARCH_UI_OPEN != "undefined" && C2_SEARCH_UI_OPEN === true ) {
    showAdvOptions();
  }
  else {
    hideAdvOptions();
    if (!searchTermsHasFocus()) {
      hideAdvOptsButton();
    }
  }

  searchTerms.keyup(function(e) {
    if (!advOptionsVisible()) {
      buttonToggler();
    }
  });

  searchTerms.focusin(function() {
    if (!advOptionsVisible()) {
      showAdvOptsButton();
    }
  });

  searchTerms.focusout(function(e) {
    if (searchTerms.val().length == 0) {
      // use timeout to workaround click on adv-options button,
      // so that the click event can also fire.
      setTimeout(function() { hideAdvOptsButton(); }, 200);
    }
  });

  allSearchButtons.click(function(e) {
    e.stopPropagation();
    var btn = $(this);
    searchForm.submit();
    // IMPORTANT disable *AFTER* submit
    searchForm.find('fieldset').prop("disabled", true);
    btn.prop("disabled", true);
    return false; // disable normal browser button action
  });

  var previewCountTimer = 0;
  var previewCountUrl = "";
  var updatePreviewCount = function() {
    var getParams = searchForm.serialize();
    var url = searchForm.attr('action') + '_count?' + getParams;
    if (url == previewCountUrl) {
      return;
    }
    previewCountUrl = url;

    if (previewCountTimer) {
      clearTimeout(previewCountTimer);
    }

    previewCountTimer = setTimeout(function() {
      $.get(url, function(resp) {
        countEl.html(resp.total);
        if (parseInt(resp.total, 10) == 1) {
          countEl.next().html('result');
        }
        else {
          countEl.next().html('results');
        }
      }).fail(function(xhr, err, msg) {
        countEl.html(0);
      });
    }, 1000); // TODO experiment with this delay
  };

  // the 'keyup' listener handles text input immediately (change waits for focus change)
  searchForm.find(':input').keyup(function(e) {
    var el = $(e.target);
    updatePreviewCount();
  });
  // the 'change' listener handles select/checkbox/radio immediately
  searchForm.find(':input').change(function(e) {
    var el = $(e.target);
    updatePreviewCount();
  });

  advOptsResetter.click(function() {
    searchForm[0].reset();
    updatePreviewCount();
    return false;
  });

  searchTerms.keyup(function(e) {
    if (e.keyCode === 13) {
      searchButton.trigger("click");
    }
  });
});
