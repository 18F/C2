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
    label = $('label[for="'+@$el.attr('id')+'"]').text();
    label

  add_label: ->
    @selectizeObj().$control_input.attr('aria-label',@form_label())

  selectizeOpts: ->
    opts = {}

    if @isFreeForm()
      opts.create = true
      opts.maxItems = 1

    if @isRemote()
      attr = @$el.attr('data-attr')
      opts.labelField = attr
      opts.searchField = [attr]
      opts.valueField = attr
      opts.sortField = [{field: '$score'}, {field: attr}]

    opts

  enable: ->
    opts = @selectizeOpts()
    @$el.form_label
    @form_label()
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
    
    
