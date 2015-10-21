class AddMinus
  constructor: ($root) ->
    this.ul = $root
    lis = @ul.find("li")
    lis.slice(1).hide()   # default to all but the first hidden
    @setupButtons(lis)

  setupButtons: (lis) ->
    lis.each (idx, li) =>
      $li = $(li)
      remove = $(document.createElement('input'))
                .attr({value: '-', type: 'button', class: "js-am-minus"})
                .click () => @remove($li)
      add = $(document.createElement('input'))
                .attr({value: '+', type: 'button', class: "js-am-plus"})
                .click () => @add()
      $li.append(remove, add)
    @disableButtons()

  remove: ($li) ->
    $li.hide()
    $li.find('input').not('.js-am-minus, .js-am-plus').val('')  # clear
    @ul.append($li)  # move to bottom
    @disableButtons()

  add: ->
    @ul.find("li").filter(":hidden").first().show()
    @disableButtons()

  disableButtons: ->
    @ul.find(".js-am-minus, .js-am-plus").prop("disabled", false)
    @ul.find(".js-am-minus").first().prop("disabled", true)
    @ul.find(".js-am-plus").last().prop("disabled", true)

$ ->
  $('[data-add-minus]').each (idx, el) ->
    new AddMinus($(el))
