#= require almond_wrapper
#= require lib/math/expression_evaluation

ttm.define "lib/math/expression_manipulation",
  ["lib/class_mixer", 'lib/math/expression_components',
    'lib/math/expression_evaluation', 'lib/object_refinement', 'logger'],
  (class_mixer, comps, expression_evaluation, object_refinement, logger_builder)->

    logger = logger_builder.build(stringify_objects: false)

    class ExpressionManipulation
      evaluate: (exp)->
        expression_evaluation.build(exp).resultingExpression()

      value: (exp)->
        result = expression_evaluation.build(exp).evaluate()
        if result then result.value() else 0

    class Calculate extends ExpressionManipulation
      invoke: (expression)->
        @evaluate(expression)
    class_mixer(Calculate)

    class Square extends ExpressionManipulation
      invoke: (expression)->
        val = @value(expression)
        comps.expression.build expression: [comps.number.build(value: val*val)]
    class_mixer(Square)

    class AppendDecimal

      onFinalExpression: (expression)->
        last = expression.last()
        if last instanceof comps.number
          new_last = last.clone()
          new_last = new_last.futureAsDecimal()
          expression.replaceLast(new_last)
        else
          new_last = comps.number.build(value: 0)
          new_last = new_last.futureAsDecimal()
          expression.append(new_last)

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expr)=> @onFinalExpression(expr))

    class_mixer(AppendDecimal)

    class AppendNumber
      initialize: (@opts)->
        @val = @opts.value

      doAppend: (expression)->
        last = expression.last()
        number_with_this_val = comps.number.build(value: @val)

        if last && last instanceof comps.number
          new_last = last.concatenate(@val)
          expression.replaceLast(new_last)
        else if (last && last instanceof comps.exponentiation) or (last && !last.isOperator())
          expression.append(comps.multiplication.build()).
            append(number_with_this_val)
        else
          expression.append(number_with_this_val)

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expr)=> @doAppend(expr))

    class_mixer(AppendNumber)

    class ExponentiateLast
      initialize: (@opts={})->

      baseExpression: (base)->
        comps.expression.buildUnlessExpression base

      powerExpression: ()->
        power = if @opts.power
          comps.expression.build expression: [
            comps.number.build(value: @opts.power)
          ]
        else
          comps.expression.build expression: []

        if @opts.power_closed
          power
        else
          power.open()

      invoke: (expression)->
        last = expression.last()

        # in the first case, our base case comes
        # from the contents of a previous part of the expression
        if it = last.preceedingSubexpression()
          base = @baseExpression(it)

        # if the previous element is an operator but has no sub-expression,
        # then we are dropping the operator and use the number prior to the operator
        else if last.isOperator()
          expression = expression.withoutLast() #remove useless operator
          base = @baseExpression(expression.last())

        # otherwise, our base is just the number before
        else
          base = @baseExpression(expression.last())

        power = @powerExpression()

        expression.replaceLast(
          comps.exponentiation.build(base: base, power: power))

    class_mixer(ExponentiateLast)

    class AppendMultiplication
      appendAction: (expression)->

        _OverrideIfOperatorOrAppend.build(expression).with comps.multiplication.build()

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expr)=> @appendAction(expr))

    class_mixer(AppendMultiplication)

    class AppendEquals
      invoke: (expression)->
        expression.append comps.equals.build()
    class_mixer(AppendEquals)

    class AppendDivision
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expr)=>
            _OverrideIfOperatorOrAppend.build(expr).with comps.division.build())
    class_mixer(AppendDivision)


    class AppendAddition
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expression)->
            _OverrideIfOperatorOrAppend.build(expression).with comps.addition.build())

    class_mixer(AppendAddition)


    class AppendSubtraction
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expression)->
            _OverrideIfOperatorOrAppend.build(expression).with comps.subtraction.build())

    class_mixer(AppendSubtraction)

    class Negation
      invoke: (expression)->
        last = expression.last()
        if last
            expression.replaceLast(last.negated())
        else
          expression

    class_mixer(Negation)

    class OpenSubExpression
      action: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.expression.build().open())

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expression).
          invokeOrDefault((expression)=> @action(expression))


    class_mixer(OpenSubExpression)

    class _FinalOpenSubExpressionApplication
      initialize: (@expr)->
        @found = false

      findAndPerformAction: (expr)->
        subexp = @nextSubExpression(expr)
        if subexp
          subexp = @findAndPerformAction(subexp)
        if @found # the child element below me was updated
          @updateWithNewSubexp(expr, subexp)
        else if expr instanceof comps.expression and expr.isOpen()
          @found = true
          @action expr
        else # not closable, not handled, return
          expr

      invoke: (@action)->
        @findAndPerformAction(@expr)

      wasFound: -> @found

      updateWithNewSubexp: (expr, subexp)->
        if expr instanceof comps.expression
          expr.replaceLast(subexp)
        else if expr instanceof comps.exponentiation
          expr.updatePower(subexp)
        else if expr instanceof comps.root
          expr.updateRadicand(subexp)

      nextSubExpression: (expr)->
        if expr instanceof comps.expression
          expr.last()
        else if expr instanceof comps.exponentiation
          expr.power()
        else if expr instanceof comps.root
          expr.radicand()
        else false

      invokeOrDefault: (@action)->
        result = @findAndPerformAction(@expr)
        if @wasFound()
          result
        else
          @action(@expr)

    class_mixer(_FinalOpenSubExpressionApplication)


    class CloseSubExpression
      invoke: (expression)->
        logger.info("CloseSubExpression#invoke")
        ret = _FinalOpenSubExpressionApplication.build(expression).
          invoke((expression)-> expression.close())
        ret
    class_mixer(CloseSubExpression)



    # TODO this needs to ahve final open sub expression application
    class AppendPi
      invoke: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.pi.build())

    class_mixer(AppendPi)

    class AppendRoot
      initialize: (@opts={})->
      invoke: (expression)->
        degree = comps.expression.build expression: [
            comps.number.build(value: @opts.degree)
          ]
        radicand = comps.expression.build(expression: []).open()
        root = comps.root.build(degree: degree, radicand: radicand)

        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(root)
    class_mixer(AppendRoot)

    class AppendVariable
      initialize: (opts={})->
        @variable_name = opts.variable
      invoke: (expression)->
        variable = comps.variable.build(name: @variable_name)
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(variable)


    class_mixer(AppendVariable)

    class SquareRoot extends ExpressionManipulation
      invoke: (expression)->
        value = @value(expression)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          num = comps.number.build value: "#{root}"
          comps.expression.buildWithContent [num]
        else
          comps.expression.buildError()
    class_mixer(SquareRoot)


    class _ImplicitMultiplication
      onNumeric: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last instanceof comps.expression || last instanceof comps.pi)
          expression.append(comps.multiplication.build())
        else
          expression

    class_mixer(_ImplicitMultiplication)

    class _OverrideIfOperatorOrAppend
      initialize: (@expression)->
      with: (operator)->
        last = @expression.last()
        if last && last.isOperator()
          if last instanceof comps.exponentiation
            if last.power().isBlank()
              @expression.replaceLast(operator)
            else
              @expression.append(operator)
          else
            @expression.replaceLast(operator)
        else
          @expression.append(operator)
    class_mixer(_OverrideIfOperatorOrAppend)


    class _TrailingOperatorHandling
      initialize: (@expression)->

      getSubexpression: ->
        last = @expression.last()
        last.preceedingSubexpression()

    class_mixer(_TrailingOperatorHandling)

    exports =
      calculate: Calculate
      square: Square
      append_decimal: AppendDecimal
      append_number: AppendNumber
      exponentiate_last: ExponentiateLast
      append_multiplication: AppendMultiplication
      append_addition: AppendAddition
      append_equals: AppendEquals
      append_subtraction: AppendSubtraction
      negate_last: Negation
      open_sub_expression: OpenSubExpression
      close_sub_expression: CloseSubExpression
      append_division: AppendDivision
      append_pi: AppendPi
      square_root: SquareRoot
      append_root: AppendRoot
      append_variable: AppendVariable

    return exports
