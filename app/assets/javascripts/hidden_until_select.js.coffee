class HiddenUntilSelect
  constructor: ($root, $hidden_el) ->
    @$hidden_el = $hidden_el
    @$controller = $root.find("##{ $hidden_el.attr('data-hide-until-select') }")
    @$controller.keyup => @checkHide()
    @$controller.change => @checkHide()
    @checkHide()

  checkHide: ->
    @$hidden_el.toggle(@$controller.val())

$ ->
  # @todo - better scope
  $scope = $(document)
  $scope.find("[data-hide-until-select]").each (idx, el) ->
    new HiddenUntilSelect($scope, $(el))
