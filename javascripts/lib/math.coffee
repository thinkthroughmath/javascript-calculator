#= require almond_wrapper
#= require lib


ttm.define "lib/math", ["lib/class_mixer"], (class_mixer)->
  class Expression

    @build_from_string: (exp)->
      BuildExpressionFromString.build(exp).buildExpression()

    @build_with_content: (content)->
      @build(expression: content)

    @build_error: (content)->
      @build(is_error: true)

    initialize: (@opts)->
      @reset()
      for k, v of @opts
        @[k] = v

    msg: (part)->
      @expression.push part

    # returns part of an expression
    last: (from_end=0)->
      @expression[@expression.length - 1 - from_end]

    first: ->
      _.first(@expression)

    reset: ->
      @expression = []

    calculate: ->
      try
        evaled = @evaluate()
        @klass.build_with_content [evaled]
      catch e
        @klass.build_error()

    set: (expression)->
      @expression = expression

    evaluate: ->
      results = (new ExpressionEvaluation @expression).results()
      results || Number.build(value: '0')

    display: ->
      ret = _(@expression).map((it)-> it.toDisplay()).join(' ')
      ret

    cloneAndAppend: (new_last)->
      expr = _.clone(@expression)
      expr.push new_last
      Expression.build(expression: expr)

    cloneAndReplaceLast: (new_last)->
      expr = _.clone(@expression)
      expr[expr.length - 1] = new_last
      Expression.build(expression: expr)

    isError: -> @is_error
    setError: -> @is_error = true

  class_mixer(Expression)


  class BuildExpressionFromString
    initialize: (@exp_string)->
    buildExpression: ->
      exp = Expression.build()
      parts = @exp_string.split(" ")
  class_mixer(BuildExpressionFromString)

  class ExpressionEvaluation
    constructor: (@expression)->
      expr = (new ExpressionEvaluationPass(@expression)).perform("parenthetical")
      expr = (new ExpressionEvaluationPass(expr)).perform("exponentiation")
      expr = (new ExpressionEvaluationPass(expr)).perform("multiplication")
      expr = (new ExpressionEvaluationPass(expr)).perform("addition")
      @eval_results = _(expr).first()

    results: ->
      @eval_results

  class_mixer(ExpressionEvaluation)

  class ExpressionEvaluationPass
    constructor: (@expression)->
      @expression_index = -1

    perform: (pass_type)->
      @expression_index = 0
      while @expression.length > @expression_index
        exp = @expression[@expression_index]
        eval_ret = exp.eval(@, pass_type)
        if eval_ret
          @expression[@expression_index] = eval_ret
        @expression_index += 1
      @expression

    previousValue: ->
      prev = @expression[@expression_index - 1]
      if prev
        prev.value()

    nextValue: ->
      next = @expression[@expression_index + 1]
      if next
        next.value()

    handledPrevious: ->
      @expression.splice(@expression_index - 1, 1)
      @expression_index -= 1

    handledSurrounding: ->
      @handledPrevious()
      @expression.splice(@expression_index + 1, 1)

    subExpression: ->
      new SubExpression(@expression, @expression_index + 1)

  # TODO rewrite this in a functional style
  class SubExpression
    constructor: (@expression, @at)->
      @subexpression = @findSubexpression()

    findSubexpression: ->
      @i = @at
      found = false
      rparens_to_find = 1
      subexpression_parts = []
      while @i < @expression.length
        current = @expression[@i]
        if current instanceof LeftParenthesis
          rparens_to_find += 1 # we encountered another subexpression
        else if current instanceof RightParenthesis
          rparens_to_find -= 1
          if rparens_to_find == 0
            found = true
            break
        else
          subexpression_parts.push(current)
        @i += 1
      if not found
        throw "There was a problem with your parentheses"
      else
        subexpression_parts

    removeFromExpression: ->
      removed = @expression.splice(@at, @i-@at+1)

    eval: ->
      (new ExpressionEvaluation(@subexpression)).results()

  class ExpressionComponent
    isOperator: -> false
    isNumber: -> false
    eval: -> @

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

    invoke: (expression)->
      last = expression.last()
      if last instanceof Number
        last.concatenate(@)
      else
        expression.msg @

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
    isOperator: -> true
    toDisplay: -> '&circ;'
    eval: (evaluation, pass)->
      return if pass != "exponentiation"

      prev = evaluation.previousValue()
      next = evaluation.nextValue()
      if prev && next
        evaluation.handledSurrounding()
        Number.build(value: Math.pow(parseFloat(prev), parseFloat(next)))
      else
        throw "Invalid Expression"

  class_mixer(Exponentiation)

  class Pi extends ExpressionComponent
    toDisplay: -> "&pi;"
    eval: ()->
      Number.build(value: Math.PI)

  class_mixer(Pi)

  class Addition extends ExpressionComponent
    toDisplay: -> "+"
    isOperator: -> true
    eval: (evaluation, pass)->
      return if pass != "addition"

      prev = evaluation.previousValue()
      next = evaluation.nextValue()
      if prev && next
        evaluation.handledSurrounding()
        Number.build(value: (parseFloat(prev) + parseFloat(next)))
      else
        throw "Invalid Expression"

  class_mixer(Addition)

  class Subtraction extends ExpressionComponent
    toDisplay: -> "-"
    isOperator: -> true
    eval: (evaluation, pass)->
      return if pass != "addition"

      prev = evaluation.previousValue()
      next = evaluation.nextValue()
      if prev && next
        evaluation.handledSurrounding()
        Number.build(value: (parseFloat(prev) - parseFloat(next)))
      else
        throw "Invalid Expression"


  class_mixer(Subtraction)

  class Multiplication extends ExpressionComponent
    isOperator: -> true
    eval: (evaluation, pass)->
      return if pass != "multiplication"
      prev = evaluation.previousValue()
      next = evaluation.nextValue()
      if prev && next
        evaluation.handledSurrounding()
        Number.build(value: (parseFloat(prev) * parseFloat(next)))
      else
        throw "Invalid Expression"

    toDisplay: -> "&times;"
  class_mixer(Multiplication)

  class Division extends ExpressionComponent
    isOperator: -> true
    toDisplay: -> "&divide;"
    eval: (evaluation, pass)->
      return if pass != "multiplication"
      prev = evaluation.previousValue()
      next = evaluation.nextValue()
      if prev && next
        evaluation.handledSurrounding()
        Number.build(value: (parseFloat(prev) / parseFloat(next)))
      else
        throw "Invalid Expression"

  class_mixer(Division)

  class LeftParenthesis extends ExpressionComponent
    toDisplay: -> "("
    eval: (expression, pass)->
      return if pass != "parenthetical"
      subexpr = expression.subExpression()
      evaluated = subexpr.eval()
      subexpr.removeFromExpression()

      evaluated

  class_mixer(LeftParenthesis)

  class RightParenthesis extends ExpressionComponent
    toDisplay: -> ")"
    eval: -> throw "Error: parentheses mismatch"

  class_mixer(RightParenthesis)

  ##############
  # commands!
  ###############

  class CalculateCommand
    invoke: (expression)->
      expression.calculate()
  class_mixer(CalculateCommand)

  class SquareCommand
    invoke: (expression)->
      expression.calculate()
      value = @valueFromExpressionOrDefault(expression)
      Expression.build_with_content([Number.build(value: value*value)])

    valueFromExpressionOrDefault: (expression)->
      if expression.first()
        parseInt(expression.first().value())
      else
        0

  class_mixer(SquareCommand)

  class DecimalCommand
    invoke: (expression)->
      last = expression.last()
      if last instanceof Number
        new_last = last.clone()
        new_last.setFutureAsDecimal()
        expression.cloneAndReplaceLast(new_last)
      else
        new_last = Number.build(value: 0)
        new_last.setFutureAsDecimal()
        expression.cloneAndAppend(new_last)
  class_mixer(DecimalCommand)

  class NumberCommand
    initialize: (@opts)->
      @val = @opts.value

    invoke: (expression)->
      expression = _ImplicitMultiplication.build().onNeitherOperatorNorNumber(expression)
      last = expression.last()
      if last && last.isNumber()
        new_last = last.concatenate(@val)
        expression.cloneAndReplaceLast(new_last)
      else
        new_last = Number.build(value: 0)
        expression.cloneAndAppend(Number.build(value: @val))

  class_mixer(NumberCommand)

  class ExponentiationCommand
    invoke: (expression)->
      _OverrideIfOperatorOrAppend.build(expression).
        with Exponentiation.build()

  class_mixer(ExponentiationCommand)

  class MultiplicationCommand
    invoke: (expression)->
      _OverrideIfOperatorOrAppend.build(expression).
        with Multiplication.build()
  class_mixer(MultiplicationCommand)

  class AdditionCommand
    invoke: (expression)->
      _OverrideIfOperatorOrAppend.build(expression).
        with Addition.build()
  class_mixer(AdditionCommand)


  class SubtractionCommand
    invoke: (expression)->
      _OverrideIfOperatorOrAppend.build(expression).
        with Subtraction.build()
  class_mixer(SubtractionCommand)

  class NegationCommand
    invoke: (expression)->
      last = expression.last()
      if last
        expression.cloneAndReplaceLast(last.negated())
      else
        expression

  class_mixer(NegationCommand)

  class LeftParenthesisCommand
    invoke: (expression)->
      _ImplicitMultiplication.build().
        onNumeric(expression).
        cloneAndAppend(LeftParenthesis.build())

  class_mixer(LeftParenthesisCommand)

  class RightParenthesisCommand
    invoke: (expression)->
      expression.cloneAndAppend(RightParenthesis.build())
  class_mixer(RightParenthesisCommand)

  class DivisionCommand
    invoke: (expression)->
      _OverrideIfOperatorOrAppend.build(expression).
        with Division.build()
  class_mixer(DivisionCommand)


  class _ImplicitMultiplication
    onNumeric: (expression)->
      last = expression.last()
      if last && (last.isNumber() || last instanceof RightParenthesis || last instanceof Pi)
        expression.cloneAndAppend(Multiplication.build())
      else
        expression

    onNeitherOperatorNorNumber: (expression)->
      last = expression.last()
      if last and !last.isNumber()  and !last.isOperator() and !(last instanceof LeftParenthesis)
        expression.cloneAndAppend(Multiplication.build())
      else
        expression

  class_mixer(_ImplicitMultiplication)

  class _OverrideIfOperatorOrAppend
    initialize: (@expression)->
    with: (operator)->
      last = @expression.last()
      if last && last.isOperator()
        @expression.cloneAndReplaceLast(operator)
      else
        @expression.cloneAndAppend(operator)
  class_mixer(_OverrideIfOperatorOrAppend)

  class PiCommand
    invoke: (expression)->
      _ImplicitMultiplication.build().
        onNumeric(expression).
        cloneAndAppend(Pi.build())

  class_mixer(PiCommand)

  class SquareRootCommand
    invoke: (expression)->
      value = expression.evaluate().value() || 0
      root = Math.sqrt(parseFloat(value))
      unless isNaN(root)
        num = Number.build value: "#{root}"
        Expression.build_with_content [num]
      else
        Expression.build_error()
  class_mixer(SquareRootCommand)


  exports =
    expression: Expression
    components:
      number: Number
      addition: Addition
      multiplication: Multiplication
      division: Division
      subtraction: Subtraction
      exponentiation: Exponentiation
      left_parenthesis: LeftParenthesis
      right_parenthesis: RightParenthesis
      pi: Pi

    commands:
      calculate: CalculateCommand
      square: SquareCommand
      decimal: DecimalCommand
      number: NumberCommand
      exponentiation: ExponentiationCommand
      multiplication: MultiplicationCommand
      addition: AdditionCommand
      subtraction: SubtractionCommand
      negation: NegationCommand
      left_parenthesis: LeftParenthesisCommand
      right_parenthesis: RightParenthesisCommand
      division: DivisionCommand
      pi: PiCommand
      square_root: SquareRootCommand
  return exports

