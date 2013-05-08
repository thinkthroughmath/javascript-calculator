
ttm.define "lib/math/expression_components",
  ["lib/class_mixer"],
  (class_mixer)->
    class Equation
      initialize: (@expression)->
        @expression ||= Expression.build()
      last: ->
        @expression.last()

      append: (val)->
        Equation.build(@expression.append(val))

      replaceLast: (val)->
        Equation.build(@expression.replaceLast(val))

      display: ->
        @expression.display()
    class_mixer(Equation)


    class Expression
      @buildWithContent: (content)->
        @build(expression: content)
      @buildError: (content)->
        @build(is_error: true)

      initialize: (@opts)->
        @reset()
        for k, v of @opts
          @[k] = v

      #msg: (part)->
      #  @expression.push part

      # returns part of an expression
      last: (from_end=0)->
        @expression[@expression.length - 1 - from_end]

      first: ->
        _.first(@expression)
      nth: (n)->
        @expression[n]
      reset: ->
        @expression = []

      set: (expression)->
        @expression = expression

      display: ->
        ret = _(@expression).map((it)-> it.toDisplay()).join(' ')
        ret

      cloneAndAppend: (new_last)->
        throw "cloneAndAppend depricated"

      append: (new_last)->
        expr = _.clone(@expression)
        expr.push new_last
        Expression.build(expression: expr)

      cloneAndReplaceLast:  ->
        throw "cloneAndReplaceLast depricated"

      replaceLast: (new_last)->
        expr = _.clone(@expression)
        expr[expr.length - 1] = new_last
        Expression.build(expression: expr)


      isError: -> @is_error
      setError: -> @is_error = true

    class_mixer(Expression)


    class ExpressionComponent
      isOperator: -> false
      isNumber: -> false

    class Number extends ExpressionComponent
      initialize: (@opts)->
        @val = @opts.value

      isNumber: -> true

      negated: ->
        value = @val * -1
        Number.build(value: value)

      toDisplay: ->
        if @hasDecimal()
          @valueAtPrecision()
        else
          if @future_as_decimal
            "#{@opts.value}."
          else
            "#{@opts.value}"

      clone: ->
        Number.build(value: @val)

      value: -> @toDisplay()

      # privates below

      valueAtPrecision: ->
        number_decimal_places = 4
        parts = "#{@val}".split(".")
        if parts[1].length > number_decimal_places
          "#{((@val*1).toFixed(number_decimal_places) * 1)}"
        else
          "#{@val}"

      concatenate: (number)->
        new_val = if @future_as_decimal
            "#{@val}.#{number}"
          else
            "#{@val}#{number}"
        Number.build(value: new_val)

      setFutureAsDecimal: ->
        @future_as_decimal = true unless @hasDecimal()

      hasDecimal: ->
        /\./.test(@opts.value)

    class_mixer(Number)

    class Exponentiation extends ExpressionComponent
      initialize: (@opts)->

      isOperator: -> true
      toDisplay: -> '&circ;'

      base: -> @opts.base
      power: -> @opts.power
    class_mixer(Exponentiation)

    class Pi extends ExpressionComponent
      toDisplay: -> "&pi;"

    class_mixer(Pi)

    class Addition extends ExpressionComponent
      toDisplay: -> "+"
      isOperator: -> true
    class_mixer(Addition)

    class Subtraction extends ExpressionComponent
      toDisplay: -> "-"
      isOperator: -> true
    class_mixer(Subtraction)

    class Multiplication extends ExpressionComponent
      isOperator: -> true

      toDisplay: -> "&times;"
    class_mixer(Multiplication)

    class Division extends ExpressionComponent
      isOperator: -> true
      toDisplay: -> "&divide;"
    class_mixer(Division)

    class LeftParenthesis extends ExpressionComponent
      toDisplay: -> "("
    class_mixer(LeftParenthesis)

    class RightParenthesis extends ExpressionComponent
      toDisplay: -> ")"

    class_mixer(RightParenthesis)
    components =
      expression: Expression
      equation: Equation
      number: Number
      addition: Addition
      multiplication: Multiplication
      division: Division
      subtraction: Subtraction
      exponentiation: Exponentiation
      left_parenthesis: LeftParenthesis
      right_parenthesis: RightParenthesis
      pi: Pi

    return components
