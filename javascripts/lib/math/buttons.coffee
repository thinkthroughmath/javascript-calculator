#= require almond_wrapper
#= require widgets/ui_elements
#= require lib

ttm.define 'lib/math/buttons', ['widgets/ui_elements', 'lib/class_mixer', 'lib/math'], (ui_elements, class_mixer, math)->

  class ButtonBuilder
    initialize: (@opts={})->
    base10Digits: (opts={})->
      for num in [0..9]
        do (num)=>
          @button({
            value: "#{num}"
            class: 'number-specifier'
          }, opts)

    exponent: (opts)->
      @button({
        value: '^'
        label: '&circ;'
        class: 'other exponent'
      }, opts)

    negative: (opts)->
      @button({
        value: 'negative'
        label: '(&ndash;)'
        class: 'number-specifier'
      }, opts)

    decimal: (opts)->
      @button({
        value: '.'
        class: 'number-specifier'
      }, opts)

    addition: (opts)->
      @button({
        value: '+'
        class: 'operation'
      }, opts)

    multiplication: (opts)->
      @button({
        value: '*'
        label: '&times;'
        class: 'operation'
      }, opts)

    division: (opts)->
      @button({
        value: '/'
        label: '&divide;'
        class: 'operation'
      }, opts)

    subtraction: (opts)->
      @button({
        value: '-'
        label: '&ndash;'
        class: 'operation'
      }, opts)


    subtraction: (opts)->
      @button({
        value: '-'
        label: '&ndash;'
        class: 'operation'
      }, opts)

    equals: (opts)->
      @button({
        value: '='
        class: 'operation'
      }, opts)

    clear: (opts)->
      @button({
        value: 'clear'
        class: 'other clear'
      }, opts)

    square: (opts)->
      @button({
        value: 'square'
        label: 'x<sup>2</sup>'
        class: 'other square'
      }, opts)

    square_root: (opts)->
      @button({
        value: 'squareroot'
        label: '&radic;<span>&#8212;</span>'
        class: 'other square-root'
      }, opts)

    lparen: (opts)->
      @button({
        value: '('
        class: 'parentheses other'
      }, opts)

    rparen: (opts)->
      @button({
        value: ')'
        class: 'parentheses other'
      }, opts)

    pi: (opts)->
      @button({
        value: 'pi'
        label: '&pi;'
        class: 'pi other'
      }, opts)


    button: (type_opts, opts)->
      ui_elements.button_builder.build(
        _.extend({}, type_opts, @opts, opts || {}))

  class_mixer(ButtonBuilder)

  return makeBuilder: ButtonBuilder.build
