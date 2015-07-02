class Selectizer
  constructor: (el) ->
    @$el = $(el)
    @dataAttr = @$el.attr('data-attr') || 'default_field'

  isFreeForm: ->
    @$el.is('input')

  form_label: ->
    $('label[for="'+@$el.attr('id')+'"]').text()

  add_label: ->
    @selectizeObj().$control_input.attr('aria-label',@form_label())

  initialChoices: ->
    initial = @$el.data('initial') || []
    $.map initial, (val) =>   # must be an object with the appropriate attribute
      result = {}
      result[@dataAttr] = val
      result

  selectizeOpts: ->
    opts = {}
    opts.options = @initialChoices()

    if @isFreeForm()
      opts.create = true
      opts.maxItems = 1

    opts.labelField = @dataAttr
    opts.searchField = [@dataAttr]
    opts.valueField = @dataAttr
    opts.sortField = [{field: '$score'}, {field: @dataAttr}]

    opts

  enable: ->
    opts = @selectizeOpts()
    @$el.selectize(opts)

  selectizeObj: ->
    @$el[0].selectize


$ ->
  $('.js-selectize').each (i, el) ->
    selectizer = new Selectizer(el)
    selectizer.enable()
    selectizer.add_label()
