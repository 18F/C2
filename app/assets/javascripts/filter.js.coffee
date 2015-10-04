class @Filter
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

  showChildren: ->
    Filter.toggle(@children(), true)

  hideAdjacentChildren: ->
    Filter.toggle(@adjacentChildren(), false)

  hideChildren: ->
    Filter.toggle(@children(), false)

  filter: ->
    if @isSelected()
      @showChildren()
      @hideAdjacentChildren()
    else
      @hideChildren()

  enable: ->
    @filter()
    @$control.change => @filter()

  @generateIn = ($scope) ->
    $scope.find('[data-filter-control]').map (idx, control) ->
      new Filter($scope, $(control))

  @toggle = ($inputOrWrappers, showOrHide) ->
    # https://www.paciellogroup.com/blog/2012/05/html5-accessibility-chops-hidden-and-aria-hidden/
    $inputOrWrappers.attr('aria-hidden', !showOrHide)
    # disable inputs so they aren't submitted with the form
    if $inputOrWrappers.is(':input')
      $inputOrWrappers.attr('disabled', !showOrHide)
    else
      $inputs = $inputOrWrappers.find(':input')
      @toggle($inputs, showOrHide)

$ ->
  #  @todo - better scope
  $scope = $(document.body)
  filters = Filter.generateIn($scope)
  for filter in filters
    filter.enable()
