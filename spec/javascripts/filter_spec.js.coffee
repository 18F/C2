#= require jquery
#= require field_filter
#= require filter_set
#= require filter
#= require spec_helper

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

  describe '#update()', ->
    it "disables the appropriate elements when checked", ->
      $content = getContent()
      $control = $('<input type="checkbox" data-filter-control="bar" value="1" checked="checked">')

      filter = new Filter($content, $control)
      filter.update()

      states = inputDisabledStates($content)
      expect(states).to.eql([false, false, false, true])

    it "disables the appropriate elements when not checked", ->
      $content = getContent()
      $control = $('<input type="checkbox" data-filter-control="bar" value="1">')

      filter = new Filter($content, $control)
      filter.update()

      states = inputDisabledStates($content)
      expect(states).to.eql([false, false, true, false])
