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
      attr = $el.attr('data-attr')
      opts.labelField = attr
      opts.searchField = [attr]
      opts.valueField = attr

    $el.selectize(opts)

    if src
      # load options from server
      selectize = $el[0].selectize
      $.getJSON src, (data) ->
        selectize.addOption(data)
