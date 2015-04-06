class Selectizer
  constructor: (el) ->
    @$el = $(el)

  isFreeForm: ->
    @$el.is('input')

  src: ->
    @$el.attr('data-src')

  isRemote: ->
    !!@src()

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
      data: {limit: 100}
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
