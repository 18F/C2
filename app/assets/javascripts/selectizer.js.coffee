class Selectizer
  constructor: (el) ->
    @$el = $(el)

  isFreeForm: ->
    @$el.is('input')

  src: ->
    @$el.attr('data-src')

  isRemote: ->
    !!@src()

  form_label: ->
    $('label[for="'+@$el.attr('id')+'"]').text()

  add_label: ->
    @selectizeObj().$control_input.attr('aria-label',@form_label())

  selectizeOpts: ->
    opts = {}
    attr = @$el.attr('data-attr')
    initialData = @$el.data('initial')
    if initialData
      opts.options = $.map initialData, (val) ->
        result = {}
        if attr
          result[attr] = val
        else
          result.text = val.text
          result.value = val.value
        result

    if @isFreeForm()
      opts.create = true
      opts.maxItems = 1

    if attr
      opts.labelField = attr
      opts.searchField = [attr]
      opts.valueField = attr
      opts.sortField = [{field: '$score'}, {field: attr}]

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
      url: @src()
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
