class Filter
  constructor: ($root, @key) ->
    @$ = (selector) -> $root.find(selector)

  addInput: ($el) ->
    $el.click () => @filter($el)
    # Initial state
    if $el.is(":checked")
      @filter($el)

  addRadios: () ->
    @$("input:radio[data-filter-control=#{ @key }]").each (idx, control) =>
      @addInput($(control))

  addChkBoxes: () ->
    @$("input:checkbox[data-filter-control=#{ @key }]").each (idx, control) =>
      @addInput($(control))

  filter: ($el) ->
    value = $el.val()
    checked = $el.is(":checked")
    @$("[data-filter-key=#{ @key }]").each (idx, el) ->
      hidden = el.getAttribute("data-filter-value") != value || !checked
      el.setAttribute("aria-hidden", hidden.toString())

  hideAll: () ->
    @$("[data-filter-key=#{ @key }]").attr("aria-hidden", true)

  this.generateIn = ($scope) ->
    filters = {}
    $scope.find("[data-filter-control]").each (idx, el) ->
      key = el.getAttribute('data-filter-control')
      if !filters.hasOwnProperty(key)
        filters[key] = new Filter($scope, key)
    filters

$ ->
  #  @todo - better scope
  $scope = $(document)
  filters = Filter.generateIn($scope)
  for key, filter of filters
    filter.hideAll()
    filter.addRadios()
    filter.addChkBoxes()
