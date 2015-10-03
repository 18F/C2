class Filter
  constructor: (@$root, @$control) ->
    @key = @$control.data('filter-control')
    @val = @$control.val()

  $: (selector) ->
    @$root.find(selector)

  children: ->
    @$("[data-filter-key=#{ @key }][data-filter-value=#{ @val }]")

  adjacentChildren: ->
    @$("[data-filter-key=#{ @key }][data-filter-value!=#{ @val }]")

  isSelected: ->
    @$control.is(':checked')

  filter: ->
    if @isSelected()
      @children().attr('aria-hidden', false)
      @adjacentChildren().attr('aria-hidden', true)
    else
      @children().attr('aria-hidden', true)

  enable: ->
    @filter()
    @$control.change => @filter()

  @generateIn = ($scope) ->
    $scope.find('[data-filter-control]').map (idx, control) ->
      new Filter($scope, $(control))

$ ->
  #  @todo - better scope
  $scope = $(document.body)
  filters = Filter.generateIn($scope)
  for filter in filters
    filter.enable()
