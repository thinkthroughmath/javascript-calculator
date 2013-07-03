#= require almond_wrapper
#= require widgets/ui_elements
#= require lib

ttm.define 'lib/math/buttons', ['widgets/ui_elements', 'lib/class_mixer'], (ui_elements, class_mixer)->

  class ButtonBuilder
    initialize: (@opts={})->
    base10Digits: (opts={})->
      for num in [0..9]
        do (num)=>
          @button({
            value: "#{num}"
            class: 'math-button number-specifier'
          }, opts)

    exponent: (opts)->
      @button({
        value: '^'
        label: '&circ;'
        class: 'math-button other exponent'
      }, opts)

    negative: (opts)->
      @button({
        value: 'negative'
        label: '(&ndash;)'
        class: 'math-button number-specifier'
      }, opts)

    decimal: (opts)->
      @button({
        value: '.'
        class: 'math-button number-specifier'
      }, opts)

    addition: (opts)->
      @button({
        value: '+'
        class: 'math-button operation'
      }, opts)

    multiplication: (opts)->
      @button({
        value: '*'
        label: '&times;'
        class: 'math-button operation'
      }, opts)

    division: (opts)->
      @button({
        value: '/'
        label: '&divide;'
        class: 'math-button operation'
      }, opts)

    subtraction: (opts)->
      @button({
        value: '-'
        label: '&ndash;'
        class: 'math-button operation'
      }, opts)


    subtraction: (opts)->
      @button({
        value: '-'
        label: '&ndash;'
        class: 'math-button operation'
      }, opts)

    equals: (opts)->
      @button({
        value: '='
        class: 'math-button operation'
      }, opts)

    clear: (opts)->
      @button({
        value: 'clear'
        class: 'math-button other clear'
      }, opts)

    square: (opts)->
      @button({
        value: 'square'
        label: 'x<sup>2</sup>'
        class: 'math-button other square'
      }, opts)

    square_root: (opts)->
      @button({
        value: 'squareroot'
        label: '&radic;<span>&#8212;</span>'
        class: 'math-button other square-root'
      }, opts)

    lparen: (opts)->
      @button({
        value: '('
        class: 'math-button parentheses other'
      }, opts)

    rparen: (opts)->
      @button({
        value: ')'
        class: 'math-button parentheses other'
      }, opts)

    pi: (opts)->
      @button({
        value: 'pi'
        label: '&pi;'
        class: 'math-button pi other'
      }, opts)

    variables: (opts)->
      variables =
        for v in opts.variables
          do (v)=>
            @button({
              value: "#{v.name}"
              class: 'math-button variable other'
              variable: v
            }, opts)
      variables

    fn: (opts)->
      @button({
        value: 'fn'
        label: '&fnof;'
        class: 'math-button other'
      }, opts)

    button: (type_opts, opts)->
      ui_elements.button_builder.build(
        _.extend({}, type_opts, @opts, opts || {}))

  class_mixer(ButtonBuilder)

  return makeBuilder: ButtonBuilder.build
