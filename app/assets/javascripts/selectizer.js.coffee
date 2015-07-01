class Selectizer
  constructor: (el) ->
    @$el = $(el)
    @dataAttr = @$el.attr('data-attr') || 'default_field'
    @dataSrc = @$el.attr('data-src')

  isFreeForm: ->
    @$el.is('input')

  isRemote: ->
    !!@dataSrc
  
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

  onOptionsLoaded: (data) ->
    selectize = @selectizeObj()
    selectize.addOption(data)

  loadRemoteOptions: ->
    # TODO make sorting smarter, e.g. approvers/vendors they have used before
    $.ajax(
      url: @dataSrc
      dataType: 'json'
      cache: true
      context: @
      success: @onOptionsLoaded
    )

  loadOptionsIfRemote: ->
    if @isRemote()
      @loadRemoteOptions()


$ ->
  $('.js-selectize').each (i, el) ->
    selectizer = new Selectizer(el)
    selectizer.enable()
    selectizer.loadOptionsIfRemote()
    selectizer.add_label()
