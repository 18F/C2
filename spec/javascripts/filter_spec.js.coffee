#= require jquery
#= require filter

describe 'Filter', ->
  describe '#children()', ->
    it "returns elements with the same key and value", ->
      $content = $('
        <div>
          <input data-filter-key="foo" data-filter-value="1"/>
          <input data-filter-key="foo" data-filter-value="2"/>
          <input data-filter-key="bar" data-filter-value="1"/>
          <input data-filter-key="bar" data-filter-value="2"/>
        </div>
      ')
      $control = $('<input type="checkbox" value="2" data-filter-control="foo"/>')

      filter = new Filter($content, $control)
      $children = filter.children()
      expect($children.length).to.equal(1)
      expect($children.data('filter-key')).to.equal('foo')
      expect($children.data('filter-value')).to.equal(2)
