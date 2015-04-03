$ ->
  $('.js-selectize').each (i, el) ->
    $el = $(el)
    src = $el.attr('data-src')
    opts = {}

    if $el.is('input')
      # allow free-form input
      opts.create = true
      opts.maxItems = 1

    if src
      # TODO make configurable
      opts.labelField = 'email_address'
      opts.searchField = ['email_address', 'first_name', 'last_name']
      opts.valueField = 'email_address'

    $el.selectize(opts)

    if src
      # load options from server
      selectize = $el[0].selectize
      $.getJSON src, (data) ->
        selectize.addOption(data)
