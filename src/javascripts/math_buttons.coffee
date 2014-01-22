ttm = thinkthroughmath

class ButtonBuilder
  initialize: (@opts={})->
    @ui_elements = @opts.ui_elements

  # Number specifiers
  base10Digits: (opts={})->
    for num in [0..9]
      do (num)=>
        @button({
          value: "#{num}"
          class: "jc--button jc--button-number"
        }, opts)

  decimal: (opts)->
    @button({
      value: "."
      class: "jc--button jc--button-decimal"
    }, opts)

  negative: (opts)->
    @button({
      value: "negative"
      label: "(&#x2013;)"
      class: "jc--button jc--button-negative"
    }, opts)

  # Operations
  addition: (opts)->
    @button({
      value: "+"
      class: "jc--button jc--button-operation jc--button-add"
    }, opts)

  subtraction: (opts)->
    @button({
      value: "-"
      label: "&#x2212;"
      class: "jc--button jc--button-operation jc--button-subtract"
    }, opts)

  multiplication: (opts)->
    @button({
      value: "*"
      label: "&#xd7;"
      class: "jc--button jc--button-operation jc--button-multiply"
    }, opts)

  division: (opts)->
    @button({
      value: "/"
      label: "&#xf7;"
      class: "jc--button jc--button-operation jc--button-divide"
    }, opts)

  equals: (opts)->
    @button({
      value: "="
      class: "jc--button jc--button-operation jc--button-equal"
    }, opts)

  # Other functions
  lparen: (opts)->
    @button({
      value: "("
      class: "jc--button jc--button-other jc--button-rParen"
    }, opts)

  rparen: (opts)->
    @button({
      value: ")"
      class: "jc--button jc--button-other jc--button-lParen"
    }, opts)

  pi: (opts)->
    @button({
      value: "pi"
      label: "&#x3c0;"
      class: "jc--button jc--button-other jc--button-pi"
    }, opts)

  fraction: (opts)->
    @button({
      value: "fraction"
      label: "<sup>a</sup>/<sub>b</sub>"
      class: "jc--button jc--button-other jc--button-fraction"
    }, opts)

  caret: (opts)->
    @button({
      value: "^"
      class: "jc--button jc--button-other jc--button-caret"
    }, opts)

  exponent: (opts)->
    base = opts.base || "x"
    power = opts.power || "y"
    @button({
      value: "exponent"
      label: "#{base}<sup>#{power}</sup>"
      class: "jc--button jc--button-other jc--button-exponent jc--button-exponent-#{base}to#{power}"
    }, opts)

  root: (opts)->
    degree = if opts.degree then "#{opts.degree}" else ""
    radicand = opts.radicand || "x"
    @button({
      value: "root"
      label: if degree then "<sup>#{degree}</sup>&#x221a;#{radicand}" else "&#x221a;#{radicand}"
      class: "jc--button jc--button-other jc--button-root jc--button-root-#{degree}of#{radicand}"
    }, opts)

  # EQ builder vars
  variables: (opts)->
    variables =
      for v in opts.variables
        do (v)=>
          @button({
            value: "#{v.name}"
            class: "jc--button jc--button-variable"
            variable: v
          }, opts)
    variables

  # Operational
  del: (opts)->
    @button({
      value: "del"
      class: "jc--button jc--button-del"
    }, opts)

  clear: (opts)->
    @button({
      value: "clear"
      class: "jc--button jc--button-clear"
    }, opts)

  button: (type_opts, opts)->
    @ui_elements.button_builder.build(
      _.extend({}, type_opts, @opts, opts || {}))

ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder)
