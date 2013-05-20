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
      clone: -> @ # by default, cloning does nothing

    class Expression extends ExpressionComponent
      @buildWithContent: (content)->
        @build(expression: content)

      @buildError: (content)->
        @build(is_error: true)

      initialize: (opts={})->
        defaults =
          is_open: false
          expression: []
          is_error: false
        opts = _.extend({}, defaults, opts)
        @expression = opts.expression
        @is_error = opts.is_error
        @is_open = opts.is_open

      clone: (new_vals={})->
        data =
          expression: _.map(@expression, (it)-> it.clone())
          is_error: @is_error
          is_open: @is_open
        @klass.build(_.extend({}, data, new_vals))

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
        @clone(expression: expr)

      replaceLast: (new_last)->
        @withoutLast().append(new_last)

      withoutLast: ->
        expr = _.clone(@expression)
        expr = expr.slice(0, expr.length-1)
        @clone(expression: expr)

      isError: -> @is_error

      isOpen: -> @is_open
      open: -> @clone(is_open: true)
      close: -> @clone(is_open: false)

      toString: ->
        tf = (it)-> it ? "t" : "f"
        subexpressions = _(@expression).chain().map((it)->
          it.toString()).join(", ").value()
        "Expr(o: #{tf @is_open}, e: #{tf @is_error}, exp: [#{subexpressions}])"


    class_mixer(Expression)


    class Number extends ExpressionComponent
      initialize: (opts)->
        @val = opts.value
        @future_as_decimal = opts.future_as_decimal

      toString: ->
        "N(#{@val})"

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
      toString: -> "Sub()"
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
