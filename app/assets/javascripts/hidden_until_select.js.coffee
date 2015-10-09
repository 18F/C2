class HiddenUntilSelect
  constructor: ($root, @$dependent) ->
    @$controller = $root.find("##{ @$dependent.attr('data-hide-until-select') }")
    @$controller.change => @checkHide()
    @checkHide()

  checkHide: ->
    @$dependent.toggle(@$controller.val())

$ ->
  # @todo - better scope
  $scope = $(document.body)
  $scope.find("[data-hide-until-select]").each (idx, el) ->
    new HiddenUntilSelect($scope, $(el))
