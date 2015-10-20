class @Filter
  constructor: (@$root, @$control) ->
    key = @$control.data('filter-control')
    val = @$control.val()
    @set = new FilterSet(@$root, key, val)

  isSelected: ->
    @$control.is(':checked')

  update: ->
    if @isSelected()
      @set.show()
    else
      @set.hide()

  enable: ->
    @update()
    @$control.change => @update()

  @generateIn = ($scope) ->
    $scope.find('[data-filter-control]').map (idx, control) ->
      new Filter($scope, $(control))

$ ->
  $scope = $(document.body)
  filters = Filter.generateIn($scope)
  for filter in filters
    filter.enable()
