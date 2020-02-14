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
          ariaLabel: "#{num}"
        }, opts)

  decimal: (opts)->
    @button({
      value: "."
      class: "jc--button jc--button-decimal"
      ariaLabel: "Decimal Separator"
    }, opts)

  negative: (opts)->
    @button({
      value: "negative"
      label: "(&#x2013;)"
      class: "jc--button jc--button-negative"
      ariaLabel: "Negative"
    }, opts)

  # Operations
  addition: (opts)->
    @button({
      value: "+"
      class: "jc--button jc--button-operation jc--button-add"
      ariaLabel: "Plus"
    }, opts)

  subtraction: (opts)->
    @button({
      value: "-"
      label: "&#x2212;"
      class: "jc--button jc--button-operation jc--button-subtract"
      ariaLabel: "Minus"
    }, opts)

  multiplication: (opts)->
    @button({
      value: "*"
      label: "&#xd7;"
      class: "jc--button jc--button-operation jc--button-multiply"
      ariaLabel: "Multiply by"
    }, opts)

  division: (opts)->
    @button({
      value: "/"
      label: "&#xf7;"
      class: "jc--button jc--button-operation jc--button-divide"
      ariaLabel: "Divide by"
    }, opts)

  equals: (opts)->
    @button({
      value: "="
      class: "jc--button jc--button-operation jc--button-equal"
      ariaLabel: "Equals"
    }, opts)

  # Other functions
  lparen: (opts)->
    @button({
      value: "("
      class: "jc--button jc--button-other jc--button-rParen"
      ariaLabel: "Left parenthesis"
    }, opts)

  rparen: (opts)->
    @button({
      value: ")"
      class: "jc--button jc--button-other jc--button-lParen"
      ariaLabel: "Right parenthesis"
    }, opts)

  pi: (opts)->
    @button({
      value: "pi"
      label: "&#x3c0;"
      class: "jc--button jc--button-other jc--button-pi"
      ariaLabel: "Pi"
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
      ariaLabel: "Caret"
    }, opts)

  exponent: (opts)->
    base = opts.base || "x"
    power = opts.power || "y"
    @button({
      value: "exponent"
      label: "#{base}<sup>#{power}</sup>"
      class: "jc--button jc--button-other jc--button-exponent jc--button-exponent-#{base}to#{power}"
      ariaLabel: "Square"
    }, opts)

  root: (opts)->
    degree = if opts.degree then "#{opts.degree}" else ""
    radicand = opts.radicand || "x"
    @button({
      value: "root"
      label: if degree then "<sup>#{degree}</sup>&#x221a;#{radicand}" else "&#x221a;#{radicand}"
      class: "jc--button jc--button-other jc--button-root jc--button-root-#{degree}of#{radicand}"
      ariaLabel: "Square root"
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
      label: "Delete"
      class: "jc--button jc--button-del"
    }, opts)

  clear: (opts)->
    @button({
      value: "clear"
      label: "Clear"
      class: "jc--button jc--button-clear"
      ariaLabel: "Clear"
    }, opts)

  button: (type_opts, opts)->
    @ui_elements.button_builder.build(
      _.extend({}, type_opts, @opts, opts || {}))

ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder)
