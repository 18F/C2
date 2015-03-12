'use strict';

// @todo - module system

var Filter = function($root, key) {
  this.$ = function(selector) {
    return $root.find(selector);
  };
  this.key = key;
};

Filter.prototype.addRadio = function($el) {
  var self = this;
  $el.click(function() {
    self.filter($el.val());
  });
  //  Initial state
  if ($el.is(':checked')) {
    self.filter($el.val());
  }
};

Filter.prototype.filter = function(value) {
  this.$('[data-filter-key=' + this.key + ']').each(function(idx, el) {
    var hidden = el.getAttribute('data-filter-value') !== value;
    el.setAttribute('aria-hidden', hidden.toString());
  });
};

Filter.prototype.hideAll = function() {
  this.$('[data-filter-key=' + this.key + ']').attr('aria-hidden', true);
};

$(document).ready(function() {
  //  @todo - better scope
  var $scope = $(document),
      filters = {};
  //  Generate all filters
  $scope.find('[data-filter-key]').each(function(idx, el) {
    var key = el.getAttribute('data-filter-key');
    if (!filters.hasOwnProperty(key)) {
      filters[key] = new Filter($scope, key);
    }
  });
  //  Add controls
  $.each(filters, function(key, filter) {
    filter.hideAll();
    filter.$('input:radio[data-filter-control=' + key + ']').each(
        function(idx, control) {
          filter.addRadio($(control));
        }
    );
  });
});
