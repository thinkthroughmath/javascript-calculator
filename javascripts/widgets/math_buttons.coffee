#= require ./base
#= require almond_wrapper
#= require widgets/ui_elements
#= require lib

math_var = (name)->
  "<span class='math-variable'>#{name}</span>"

class ButtonBuilder
  initialize: (@opts={})->
    @ui_elements = @opts.ui_elements

  base10Digits: (opts={})->
    for num in [0..9]
      do (num)=>
        @button({
          value: "#{num}"
          class: 'math-button number-specifier number'
        }, opts)

  caret: (opts)->
    @button({
      value: '^'
      label: '&circ;'
      class: 'math-button other caret'
    }, opts)

  negative: (opts)->
    @button({
      value: 'negative'
      label: '(&ndash;)'
      class: 'math-button number-specifier negative'
    }, opts)

  negative_slash_positive: (opts)->
    @button({
      value: '-/+'
      label: "&ndash;/+"
      class: 'math-button number-specifier negative-slash-positive'
    }, opts)

  decimal: (opts)->
    @button({
      value: '.'
      class: 'math-button number-specifier decimal'
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
      class: 'math-button operation equal'
    }, opts)

  clear: (opts)->
    @button({
      value: 'clear'
      class: 'math-button other clear'
    }, opts)

  del: (opts)->
    @button({
      value: 'del'
      class: 'math-button other del'
    }, opts)

  square: (opts)->
    @button({
      value: 'square'
      label: "#{math_var('x')}<sup>2</sup>"
      class: 'math-button other square'
    }, opts)

  exponent: (opts)->
    base = opts.base || math_var('x')
    power = opts.power || math_var('y')
    @button({
      value: 'exponent'
      label: "#{base}<sup>#{power}</sup>"
      class: 'math-button other exponent'
    }, opts)

  root: (opts)->
    degree = if opts.degree
      "<div class='degree'>#{opts.degree}</div>"
    else
      ""
    radicand = if opts.radicand
      "<div class='radicand'>#{opts.radicand}</div>"
    else
      "<div class='radicand'>#{math_var('x')}</div>"

    @button({
      value: 'root'
      label: """
        #{degree}
        #{radicand}
        <div class='radix'>&radic;</div>
        <div class='vinculum'>&#8212;</div>
      """
      class: 'math-button other root'
    }, opts)


  fraction: (opts)->
    @button({
      value: 'fraction'
      label: """
        <div class='numerator'>#{math_var('a')}</div>
        <div class='vinculum'>&#8212;</div>
        <div class='denominator'>#{math_var('b')}</div>
        """
      class: 'math-button other fraction'
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
    value = if opts.name
      "function[#{opts.name}]"
    else
      "function"
    @button({
      value: value
      label: '&fnof;'
      class: 'math-button other function'
    }, opts)

  button: (type_opts, opts)->
    @ui_elements.button_builder.build(
      _.extend({}, type_opts, @opts, opts || {}))

window.ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder)
