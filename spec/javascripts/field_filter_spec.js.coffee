#= require spec_helper

describe 'FieldFilter', ->
  describe '#show()', ->
    it "enables inputs", ->
      $input = $('<input disabled="disabled">')

      filter = new FieldFilter($input)
      filter.show()

      expect($input.is(':disabled')).to.be.false

    it "enables text areas", ->
      $textarea = $('<textarea disabled="disabled">')

      filter = new FieldFilter($textarea)
      filter.show()

      expect($textarea.is(':disabled')).to.be.false

    it "enables nested inputs", ->
      $content = $('<div><input disabled="disabled"></div>')

      filter = new FieldFilter($content)
      filter.show()

      $input = $content.find('input')
      expect($input.is(':disabled')).to.be.false

    it "enables nested text areas", ->
      $content = $('<div><textarea disabled="disabled"></div>')

      filter = new FieldFilter($content)
      filter.show()

      $textarea = $content.find('textarea')
      expect($textarea.is(':disabled')).to.be.false

  describe '#hide()', ->
    it "disables inputs", ->
      $input = $('<input>')

      filter = new FieldFilter($input)
      filter.hide()

      expect($input.is(':disabled')).to.be.true

    it "disables text areas", ->
      $textarea = $('<textarea>')

      filter = new FieldFilter($textarea)
      filter.hide()

      expect($textarea.is(':disabled')).to.be.true

    it "disables nested inputs", ->
      $content = $('<div><input></div>')

      filter = new FieldFilter($content)
      filter.hide()

      $input = $content.find('input')
      expect($input.is(':disabled')).to.be.true

    it "disables nested text areas", ->
      $content = $('<div><textarea></div>')

      filter = new FieldFilter($content)
      filter.hide()

      $textarea = $content.find('textarea')
      expect($textarea.is(':disabled')).to.be.true
