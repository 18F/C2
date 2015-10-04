class @FilterSet
  constructor: (@$root, @key, @val) ->

  $: (selector) ->
    @$root.find(selector)

  children: ->
    @$("[data-filter-key=#{ @key }][data-filter-value=#{ @val }]")

  adjacentChildren: ->
    @$("[data-filter-key=#{ @key }][data-filter-value!=#{ @val }]")

  showChildren: ->
    filter = new FieldFilter(@children())
    filter.show()

  hideAdjacentChildren: ->
    filter = new FieldFilter(@adjacentChildren())
    filter.hide()

  show: ->
    @showChildren()
    @hideAdjacentChildren()

  hide: ->
    filter = new FieldFilter(@children())
    filter.hide()
