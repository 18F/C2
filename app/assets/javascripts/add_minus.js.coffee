class AddMinus
  constructor: ($root) ->
    @ul = $root
    lis = @ul.find("li")
    lis.slice(1).hide()   # default to all but the first hidden
    @setupButtons(lis)

  setupButtons: (lis) ->
    klass = "button tiny"
    minusKlass = "js-am-minus " + klass
    plusKlass = "js-am-plus " + klass
    lis.each (idx, li) =>
      $li = $(li)
      remove = $(document.createElement("input"))
              .attr({value: "-", type: "button", class: minusKlass})
              .click () => @remove($li)
      add = $(document.createElement("input"))
              .attr({value: "+", type: "button", class: plusKlass})
              .click () => @add()
      $li.append(remove, add)
    @disableButtons()

  remove: ($li) ->
    $li.hide()
    $li.find("input").not(".js-am-minus, .js-am-plus").val("")  # clear
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
  $("[data-add-minus]").each (idx, el) ->
    new AddMinus($(el))
