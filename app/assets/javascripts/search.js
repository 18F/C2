$(document).ready(function() {

  var searchUI = $(".m-search-ui"),
  advOptsFieldset = $("fieldset.adv"),
  advOptsControlsFieldset = $("fieldset.controls"),
  searchTerms = $(".m-search-ui .search-terms"),
  searchButton = $("#search-button"),
  searchMagGlass = $(".m-search-ui .input-group-addon.magnifier"),
  advOptsButton = $("#adv-options"),
  advOptsToggler = $("a.adv-options"),
  advOptsCloser = $(".adv-controls .closer"),
  allSearchButtons = $(".m-search-ui button.search"),
  searchForm = $("form.search"),
  countEl = $(".results-count-preview .count"),
  advOptsResetter = $("a.resetter"),
  formHasFocus = false;

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
  else if (typeof C2_SEARCH_ADV_QUERY != "undefined" && C2_SEARCH_ADV_QUERY === true) {
    hideAdvOptions();
    showAdvOptsButton();
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
      showAdvOptions();
    }
  });

  searchForm.on("focusout",function(e) {
    if (searchTerms.val().length == 0) {
      // use timeout to workaround click on adv-options button,
      // so that the click event can also fire.
      // console.log(searchForm.find('input').is(':focus'));
      setTimeout(function() { hideAdvOptsButton(); }, 200);
      setTimeout(function() { 
        if(!formHasFocus){
          hideAdvOptions();
          hideAdvOptsButton();
        }
      }, 200);
    }
  });
  $('body').on("click", function(e){
    formHasFocus = false;
    setTimeout(function(){
      if(!formHasFocus){
        hideAdvOptions();
        hideAdvOptsButton();
      }
    }, 200)
  });

  searchForm.find("button, input, select, a, div, label").on("focusout", function(e) {
    formHasFocus = false;
  });

  searchForm.on("click", function(e) {
    formHasFocus = true;
    setTimeout(function(){formHasFocus = true;}, 10);
  });

  searchForm.find("button, input, select, a, div, label").on("focusin", function(e) {
    formHasFocus = true;
    setTimeout(function(){formHasFocus = true;}, 10);
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
