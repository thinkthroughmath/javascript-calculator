ttm = thinkthroughmath

math_var = (name)->
  "<span class='jc--mathvariable'>#{name}</span>"

class ButtonBuilder
  initialize: (@opts={})->
    @ui_elements = @opts.ui_elements

  # Number specifiers
  base10Digits: (opts={})->
    for num in [0..9]
      do (num)=>
        @button({
          value: "#{num}"
          class: 'jc--button jc--button-numberspecifier jc--button-number'
        }, opts)

  negative: (opts)->
    @button({
      value: 'negative'
      label: '&#x2013;'
      class: 'jc--button jc--button-numberspecifier jc--button-negative'
    }, opts)

  decimal: (opts)->
    @button({
      value: '.'
      class: 'jc--button jc--button-numberspecifier jc--button-decimal'
    }, opts)

  # Operations
  addition: (opts)->
    @button({
      value: '+'
      class: 'jc--button jc--button-operation'
    }, opts)

  subtraction: (opts)->
    @button({
      value: '-'
      label: '&#x2212;'
      class: 'jc--button jc--button-operation'
    }, opts)

  multiplication: (opts)->
    @button({
      value: '*'
      label: '&#xd7;'
      class: 'jc--button jc--button-operation'
    }, opts)

  division: (opts)->
    @button({
      value: '/'
      label: '&#xf7;'
      class: 'jc--button jc--button-operation'
    }, opts)

  equals: (opts)->
    @button({
      value: '='
      class: 'jc--button jc--button-operation jc--button-equal'
    }, opts)

  # Other functions
  lparen: (opts)->
    @button({
      value: '('
      class: 'jc--button jc--button-other jc--button-parentheses'
    }, opts)

  rparen: (opts)->
    @button({
      value: ')'
      class: 'jc--button jc--button-other jc--button-parentheses'
    }, opts)

  pi: (opts)->
    @button({
      value: 'pi'
      label: '&#x3c0;'
      class: 'jc--button jc--button-other jc--button-pi'
    }, opts)

  root: (opts)->
    # TODO: This probably has some important functionality in the
    # equation builder. @Joel, let me know what's up.
    # degree = if opts.degree
    #   "<div class='degree'>#{opts.degree}</div>"
    # else
    #   ""
    # radicand = if opts.radicand
    #   "<div class='radicand'>#{opts.radicand}</div>"
    # else
    #   "<div class='radicand'>#{math_var('x')}</div>"

    @button({
      value: 'root'
      label: '&#x221a;'
      # label: """
      #   #{degree}
      #   #{radicand}
      #   <div class='radix'>&radic;</div>
      #   <div class='vinculum'>&#8212;</div>
      # """
      class: 'jc--button jc--button-other jc--button-root'
    }, opts)

  clear: (opts)->
    @button({
      value: 'clear'
      class: 'jc--button jc--button-other jc--button-clear'
    }, opts)

  square: (opts)->
    @button({
      value: 'square'
      label: '&#xb2;'
      class: 'jc--button jc--button-other jc--button-square'
    }, opts)

  # Buttons for the Equation Builder component
  negative_slash_positive: (opts)->
    @button({
      value: '-/+'
      label: '&#xb1;'
      class: 'jc--button jc--button-numberspecifier jc--button-negativepositive'
    }, opts)

  exponent: (opts)->
    base = opts.base || math_var('x')
    power = opts.power || math_var('y')
    @button({
      value: 'exponent'
      label: "#{base}<sup>#{power}</sup>"
      class: 'jc--button jc--button-other jc--button-exponent'
    }, opts)

  del: (opts)->
    @button({
      value: 'del'
      class: 'jc--button jc--button-other jc--button-del'
    }, opts)

  fraction: (opts)->
    @button({
      value: 'fraction'
      label: """
        <div class='jc--numerator'>a</div>
        <div class='jc--vinculum'>&#8212;</div>
        <div class='jc--denominator'>b</div>
        """
      class: 'jc--button jc--button-other jc--button-fraction'
    }, opts)

  caret: (opts)->
    @button({
      value: '^'
      class: 'jc--button jc--button-other jc--button-caret'
    }, opts)

  variables: (opts)->
    variables =
      for v in opts.variables
        do (v)=>
          @button({
            value: "#{v.name}"
            class: 'jc--button jc--button-other jc--button-variable'
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
      class: 'jc--button jc--button-other jc--button-function'
    }, opts)

  button: (type_opts, opts)->
    @ui_elements.button_builder.build(
      _.extend({}, type_opts, @opts, opts || {}))

ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder)
