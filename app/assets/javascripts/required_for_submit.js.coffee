class RequiredForSubmit
  constructor: ($root, $submit) ->
    @$submit = $submit
    @$controller = $root.find("##{ $submit.attr('data-disable-if-empty') }")
    @$controller.keyup => @checkDisable()
    @$controller.change => @checkDisable()
    @checkDisable()

  checkDisable: ->
    @$submit.prop 'disabled', !@$controller.val()

$ ->
  # @todo - better scope
  $scope = $(document)
  $scope.find("[data-disable-if-empty]").each (idx, el) ->
    new RequiredForSubmit($scope, $(el))
