ttm.define "lib/math/expression_components",
  ["lib/class_mixer", 'lib/object_refinement'],
  (class_mixer, object_refinement)->

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



    class ExpressionComponent
      isOperator: -> false
      isNumber: -> false
      preceedingSubexpression: -> false

    class Expression extends ExpressionComponent
      @buildWithContent: (content)->
        @build(expression: content)
      @buildError: (content)->
        @build(is_error: true)

      initialize: (opts)->
        @reset()
        for k, v of opts
          @[k] = v
      # returns part of an expression
      last: (from_end=0)->
        @expression[@expression.length - 1 - from_end]

      first: ->
        _.first(@expression)
      nth: (n)->
        @expression[n]
      reset: ->
        @expression = []

      size: ->
        _(@expression).size();

      set: (expression)->
        @expression = expression

      append: (new_last)->
        expr = _.clone(@expression)
        expr.push new_last
        Expression.build(expression: expr)

      replaceLast: (new_last)->
        expr = _.clone(@expression)
        expr[expr.length - 1] = new_last
        Expression.build(expression: expr)

      withoutLast: ->
        expr = _.clone(@expression)
        expr = expr.slice(0, expr.length-1)
        Expression.build(expression: expr)

      isError: -> @is_error
      setError: -> @is_error = true

    class_mixer(Expression)


    class Number extends ExpressionComponent
      initialize: (opts)->
        @val = opts.value
        @future_as_decimal = opts.future_as_decimal

      isNumber: -> true

      negated: ->
        value = @val * -1
        Number.build(value: value)

      toCalculable: ->
        parseFloat(@val)

      clone: (opts={})->
        opts = _.extend({},
          {
            value: @val
            future_as_decimal: @future_as_decimal
          },
          opts)
        Number.build(opts)

      value: -> @val

      concatenate: (number)->
        new_val =
          if @future_as_decimal
            "#{@val}.#{number}"
          else
            "#{@val}#{number}"
        Number.build(value: new_val)

      futureAsDecimal: ->
        future_as_decimal = !@hasDecimal()
        @clone(future_as_decimal: future_as_decimal)

      hasDecimal: ->
        /\./.test(@val)

    class_mixer(Number)

    class Exponentiation extends ExpressionComponent
      initialize: (opts={})->
        @baseval = opts.base
        @powerval = opts.power
      isOperator: -> true

      base: -> @baseval
      power: -> @powerval

      preceedingSubexpression: -> @base()

      updatePower: (power)->
        @klass.build base: @base(), power: power

    class_mixer(Exponentiation)

    class Pi extends ExpressionComponent
      toDisplay: -> "&pi;"

    class_mixer(Pi)

    class Addition extends ExpressionComponent

      isOperator: -> true
    class_mixer(Addition)

    class Subtraction extends ExpressionComponent
      toDisplay: -> "-"
      isOperator: -> true
      toString: -> "[object Multiplication]"
    class_mixer(Subtraction)

    class Multiplication extends ExpressionComponent
      isOperator: -> true
      toString: -> "Mult()"
    class_mixer(Multiplication)

    class Division extends ExpressionComponent
      isOperator: -> true
      toString: -> "Div()"
    class_mixer(Division)

    class LeftParenthesis extends ExpressionComponent
      toDisplay: -> "("
    class_mixer(LeftParenthesis)

    class RightParenthesis extends ExpressionComponent
      toDisplay: -> ")"
    class_mixer(RightParenthesis)


    class Blank extends ExpressionComponent
      toDisplay: -> ""
    class_mixer(Blank)

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
      blank: Blank

    return components
