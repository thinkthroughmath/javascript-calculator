#= require almond
#= require lib


define "lib/math", ["lib/class_mixer"], (class_mixer)->
  class Expression

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
    last: ->
      _.last(@expression)

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
      @expression.splice(@at, @i)

    eval: ->
      (new ExpressionEvaluation(@subexpression)).results()

  class ExpressionComponent
    handled: ->
      @is_handled = true
    isHandled: ->
      @is_handled
    eval: -> @

  class Number extends ExpressionComponent
    initialize: (@opts)->
      @val = @opts.value

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

  class Square extends ExpressionComponent
    toDisplay: -> "<sup>2</sup>"
    eval: (evaluation, pass)->
      return if pass != "exponentiation"
      prev = evaluation.previousValue()
      if prev
        evaluation.handledPrevious()
        squared = parseFloat(prev) * parseFloat(prev)
        Number.build(value: squared)
      else
        throw "Invalid Expression"

  class_mixer(Square)


  class Exponentiation extends ExpressionComponent
    toDisplay: -> "^"
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
    eval: ->
      Number.build(value: Math.PI)

  class_mixer(Pi)

  class Addition extends ExpressionComponent
    toDisplay: -> "+"
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
      last = expression.last()
      if last instanceof Number
        new_last = last.concatenate(@val)
        expression.cloneAndReplaceLast(new_last)
      else
        new_last = Number.build(value: 0)
        expression.cloneAndAppend(Number.build(value: @val))

  class_mixer(NumberCommand)

  class ExponentiationCommand
    invoke: (expression)->
      expression.cloneAndAppend(Exponentiation.build())

  class_mixer(ExponentiationCommand)

  class MultiplicationCommand
    invoke: (expression)->
      expression.cloneAndAppend(Multiplication.build())
  class_mixer(MultiplicationCommand)

  class AdditionCommand
    invoke: (expression)->
      expression.cloneAndAppend(Addition.build())
  class_mixer(AdditionCommand)


  class SubtractionCommand
    invoke: (expression)->
      expression.cloneAndAppend(Subtraction.build())
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
      expression.cloneAndAppend(LeftParenthesis.build())
  class_mixer(LeftParenthesisCommand)

  class RightParenthesisCommand
    invoke: (expression)->
      expression.cloneAndAppend(RightParenthesis.build())
  class_mixer(RightParenthesisCommand)

  class DivisionCommand
    invoke: (expression)->
      expression.cloneAndAppend(Division.build())
  class_mixer(DivisionCommand)

  class PiCommand
    invoke: (expression)->
      expression.cloneAndAppend(Pi.build())
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

