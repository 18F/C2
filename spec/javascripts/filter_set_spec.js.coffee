#= require jquery
#= require field_filter
#= require filter_set
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
      set = new FilterSet(getContent(), 'foo', 2)
      $children = set.children()

      expect($children.length).to.eql(1)
      expect($children.data('filter-key')).to.eql('foo')
      expect($children.data('filter-value')).to.eql(2)

  describe '#cousins()', ->
    it "returns elements with the same key but a different value", ->
      set = new FilterSet(getContent(), 'foo', 2)
      $cousins = set.cousins()

      expect($cousins.length).to.eql(1)
      expect($cousins.data('filter-key')).to.eql('foo')
      expect($cousins.data('filter-value')).to.eql(1)

  describe '#show()', ->
    it "disables all inputs with matching keys but different values", ->
      $content = getContent()
      set = new FilterSet($content, 'bar', 1)
      set.show()

      states = inputDisabledStates($content)
      expect(states).to.eql([false, false, false, true])

  describe '#hide()', ->
    it "disables all inputs with matching keys and values", ->
      $content = getContent()
      set = new FilterSet($content, 'bar', 1)
      set.hide()

      states = inputDisabledStates($content)
      expect(states).to.eql([false, false, true, false])
