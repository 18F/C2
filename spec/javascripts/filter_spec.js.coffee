#= require jquery
#= require filter

describe 'Filter', ->
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
      $control = $('<input type="checkbox" value="2" data-filter-control="foo"/>')

      filter = new Filter(getContent(), $control)
      $children = filter.children()

      expect($children.length).to.equal(1)
      expect($children.data('filter-key')).to.equal('foo')
      expect($children.data('filter-value')).to.equal(2)

  describe '#adjacentChildren()', ->
    it "returns elements with the same key but a different value", ->
      $control = $('<input type="checkbox" value="2" data-filter-control="foo"/>')

      filter = new Filter(getContent(), $control)
      $adjacentChildren = filter.adjacentChildren()

      expect($adjacentChildren.length).to.equal(1)
      expect($adjacentChildren.data('filter-key')).to.equal('foo')
      expect($adjacentChildren.data('filter-value')).to.equal(1)

  describe '.toggle()', ->
    it "disables the inputs", ->
      $content = $('
        <div>
          <label for="foo">Foo</label>
          <input name="foo">
        </div>
      ')
      Filter.toggle($content, false)
      $input = $content.find('input')
      expect($input.is(':disabled')).to.be.true

    it "disables the text areas", ->
      $content = $('
        <div>
          <label for="foo">Foo</label>
          <textarea name="foo">
        </div>
      ')
      Filter.toggle($content, false)
      $textarea = $content.find('textarea')
      expect($textarea.is(':disabled')).to.be.true

    it "enables the inputs", ->
      $content = $('
        <div>
          <label for="foo">Foo</label>
          <input name="foo" disabled="disabled">
        </div>
      ')
      Filter.toggle($content, true)
      $input = $content.find('input')
      expect($input.is(':disabled')).to.be.false

    it "disables the text areas", ->
      $content = $('
        <div>
          <label for="foo">Foo</label>
          <textarea name="foo" disabled="disabled">
        </div>
      ')
      Filter.toggle($content, true)
      $textarea = $content.find('textarea')
      expect($textarea.is(':disabled')).to.be.false
