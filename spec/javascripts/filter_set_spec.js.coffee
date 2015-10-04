#= require spec_helper

describe 'FilterSet', ->
  getContent = ->
    $('
      <div>
        <input data-filter-key="foo" data-filter-value="1"/>
        <input data-filter-key="foo" data-filter-value="2"/>
        <input data-filter-key="bar" data-filter-value="1"/>
        <input data-filter-key="bar" data-filter-value="2"/>
      </div>
    ')

  describe '#children()', ->
    it "returns elements with the same key and value", ->
      filter = new FilterSet(getContent(), 'foo', 2)
      $children = filter.children()

      expect($children.length).to.eql(1)
      expect($children.data('filter-key')).to.eql('foo')
      expect($children.data('filter-value')).to.eql(2)

  describe '#adjacentChildren()', ->
    it "returns elements with the same key but a different value", ->
      filter = new FilterSet(getContent(), 'foo', 2)
      $adjacentChildren = filter.adjacentChildren()

      expect($adjacentChildren.length).to.eql(1)
      expect($adjacentChildren.data('filter-key')).to.eql('foo')
      expect($adjacentChildren.data('filter-value')).to.eql(1)

  describe '#show()', ->
    it "disables all inputs with matching keys but different values", ->
      $content = getContent()
      set = new FilterSet($content, 'bar', 1)
      set.show()

      disabled = $content.find('input').map (i, input) ->
        $(input).is(':disabled')
      expect(disabled.get()).to.eql([false, false, false, true])

  describe '#hide()', ->
    it "disables all inputs with matching keys and values", ->
      $content = getContent()
      set = new FilterSet($content, 'bar', 1)
      set.hide()

      disabled = $content.find('input').map (i, input) ->
        $(input).is(':disabled')
      expect(disabled.get()).to.eql([false, false, true, false])
