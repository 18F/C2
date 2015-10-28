class @FilterSet
  constructor: (@$root, @key, @val) ->

  $: (selector) ->
    @$root.find(selector)

  children: ->
    @$("[data-filter-key=#{ @key }][data-filter-value=#{ @val }]")

  cousins: ->
    @$("[data-filter-key=#{ @key }][data-filter-value!=#{ @val }]")

  showChildren: ->
    filter = new FieldFilter(@children())
    filter.show()

  hideCousins: ->
    filter = new FieldFilter(@cousins())
    filter.hide()

  show: ->
    @showChildren()
    @hideCousins()

  hide: ->
    filter = new FieldFilter(@children())
    filter.hide()
