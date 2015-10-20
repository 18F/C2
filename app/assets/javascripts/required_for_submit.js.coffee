class RequiredForSubmit
  constructor: ($root, $submit) ->
    @$submit = $submit
    @$controller = $root.find("##{ $submit.attr('data-disable-if-empty') }")
    @$controller.keyup => @checkDisable()
    @$controller.change => @checkDisable()
    @checkDisable()

  checkDisable: ->
    @$submit.prop 'disabled', (@$controller.val() == '')

$ ->
  $scope = $(document.body)
  $scope.find("[data-disable-if-empty]").each (idx, el) ->
    new RequiredForSubmit($scope, $(el))
