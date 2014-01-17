ttm = thinkthroughmath

# Temp
math_var = (name)->
  "#{name}"

class ButtonBuilder
  initialize: (@opts={})->
    @ui_elements = @opts.ui_elements

  # Number specifiers
  base10Digits: (opts={})->
    for num in [0..9]
      do (num)=>
        @button({
          value: "#{num}"
          class: 'jc--button jc--button-number'
        }, opts)

  decimal: (opts)->
    @button({
      value: '.'
      class: 'jc--button jc--button-decimal'
    }, opts)

  negative: (opts)->
    @button({
      value: 'negative'
      label: '&#x2013;'
      class: 'jc--button jc--button-negative'
    }, opts)

  negative_slash_positive: (opts)-> # EQ builder
    @button({
      value: '-/+'
      label: '&#xb1;'
      class: 'jc--button jc--button-negativepositive'
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

  fraction: (opts)->
    @button({
      value: 'fraction'
      label: "<sup>a</sup>/<sub>b</sub>"
      class: 'jc--button jc--button-other jc--button-fraction'
    }, opts)

  square: (opts)->
    @button({
      value: 'square'
      label: 'x<sup>2</sup>'
      class: 'jc--button jc--button-other jc--button-square'
    }, opts)

  caret: (opts)->
    @button({
      value: '^'
      class: 'jc--button jc--button-other jc--button-caret'
    }, opts)

  exponent: (opts)->
    base = opts.base || 'x'
    power = opts.power || 'y'
    @button({
      value: 'exponent'
      label: "#{base}<sup>#{power}</sup>"
      class: 'jc--button jc--button-other jc--button-exponent'
    }, opts)

  root: (opts)->
    degree = if opts.degree then "<sup>#{opts.degree}</sup>" else ""
    radicand = opts.radicand || 'x'

    @button({
      value: 'root'
      label: "#{degree}&#x221a;#{radicand}"
      class: 'jc--button jc--button-other jc--button-root'
    }, opts)

  # EQ builder vars
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

  # Operational
  del: (opts)->
    @button({
      value: 'del'
      class: 'jc--button jc--button-del'
    }, opts)

  clear: (opts)->
    @button({
      value: 'clear'
      class: 'jc--button jc--button-clear'
    }, opts)

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
