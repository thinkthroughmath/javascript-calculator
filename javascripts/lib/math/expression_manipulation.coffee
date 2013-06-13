#= require almond_wrapper
#= require lib/math/expression_evaluation
#= require lib/math/expression_traversal

ttm.define "lib/math/expression_manipulation",
  ["lib/class_mixer",
    'lib/math/expression_evaluation', 'lib/object_refinement'],
  (class_mixer, expression_evaluation, object_refinement)->

    class ExpressionManipulation
      initialize: (opts={})->
        @comps = opts.component_source

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
        @comps.build_expression expression: [@comps.build_number(value: val*val)]
    class_mixer(Square)

    class AppendDecimal extends ExpressionManipulation

      onFinalExpression: (expression)->
        last = expression.last()
        if last instanceof @comps.classes.number
          new_last = last.clone()
          new_last = new_last.futureAsDecimal()
          expression.replaceLast(new_last)
        else
          new_last = @comps.build_number(value: 0)
          new_last = new_last.futureAsDecimal()
          expression.append(new_last)

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expr)=> @onFinalExpression(expr))

    class_mixer(AppendDecimal)

    class AppendNumber extends ExpressionManipulation
      initialize: (opts={})->
        super
        @val = opts.value

      doAppend: (expression)->
        last = expression.last()
        number_with_this_val = @comps.build_number(value: @val)

        if last && last instanceof @comps.classes.number
          new_last = last.concatenate(@val)
          expression.replaceLast(new_last)
        else if (last && last instanceof @comps.classes.exponentiation) or (last && !last.isOperator())
          expression.append(@comps.build_multiplication()).
            append(number_with_this_val)
        else
          expression.append(number_with_this_val)

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expr)=> @doAppend(expr))

    class_mixer(AppendNumber)

    class ExponentiateLast extends ExpressionManipulation
      initialize: (opts={})->
        super
        @power = opts.power
        @power_closed = opts.power_closed

      baseExpression: (base)->
        if base instanceof @comps.classes.expression
          base
        else
          @comps.build_expression expression: [base]

      powerExpression: ()->
        power = if @power
          @comps.build_expression expression: [
            @comps.build_number(value: @power)
          ]
        else
          @comps.build_expression expression: []

        if @power_closed
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
          @comps.build_exponentiation(base: base, power: power))

    class_mixer(ExponentiateLast)

    class AppendMultiplication extends ExpressionManipulation
      appendAction: (expression)->
        _OverrideIfOperatorOrAppend.build(@comps, expression).with @comps.build_multiplication()

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expr)=> @appendAction(expr))

    class_mixer(AppendMultiplication)

    class AppendEquals extends ExpressionManipulation
      invoke: (expression)->
        expression.append @comps.build_equals()
    class_mixer(AppendEquals)

    class AppendDivision extends ExpressionManipulation
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expr)=>
            _OverrideIfOperatorOrAppend.build(@comps, expr).with @comps.build_division())
    class_mixer(AppendDivision)


    class AppendAddition extends ExpressionManipulation
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expression)->
            _OverrideIfOperatorOrAppend.build(@comps, expression).with @comps.build_addition())

    class_mixer(AppendAddition)


    class AppendSubtraction extends ExpressionManipulation
      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expression)=>
            _OverrideIfOperatorOrAppend.build(@comps, expression).with @comps.build_subtraction())

    class_mixer(AppendSubtraction)

    class Negation extends ExpressionManipulation
      invoke: (expression)->
        last = expression.last()
        if last
            expression.replaceLast(last.negated())
        else
          expression

    class_mixer(Negation)

    class OpenSubExpression extends ExpressionManipulation
      action: (expression)->
        _ImplicitMultiplication.build(@comps).
          onNumeric(expression).
          append(@comps.build_expression().open())

      invoke: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invokeOrDefault((expression)=> @action(expression))


    class_mixer(OpenSubExpression)

    class _FinalOpenSubExpressionApplication
      initialize: (opts={})->
        @comps = opts.comps
        @expr = opts.expr
        @found = false

      findAndPerformAction: (expr)->
        subexp = @nextSubExpression(expr)
        if subexp
          subexp = @findAndPerformAction(subexp)
        if @found # the child element below me was updated
          @updateWithNewSubexp(expr, subexp)
        else if expr instanceof @comps.classes.expression and expr.isOpen()
          @found = true
          @action expr
        else # not closable, not handled, return
          expr

      invoke: (@action)->
        @findAndPerformAction(@expr)

      wasFound: -> @found

      updateWithNewSubexp: (expr, subexp)->
        if expr instanceof @comps.classes.expression
          expr.replaceLast(subexp)
        else if expr instanceof @comps.classes.exponentiation
          expr.updatePower(subexp)
        else if expr instanceof @comps.classes.root
          expr.updateRadicand(subexp)

      nextSubExpression: (expr)->
        if expr instanceof @comps.classes.expression
          expr.last()
        else if expr instanceof @comps.classes.exponentiation
          expr.power()
        else if expr instanceof @comps.classes.root
          expr.radicand()
        else false

      invokeOrDefault: (@action)->
        result = @findAndPerformAction(@expr)
        if @wasFound()
          result
        else
          @action(@expr)

    class_mixer(_FinalOpenSubExpressionApplication)


    class CloseSubExpression extends ExpressionManipulation
      invoke: (expression)->
        ret = _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          invoke((expression)-> expression.close())
        ret
    class_mixer(CloseSubExpression)

    # TODO this needs to ahve final open sub expression application
    class AppendPi extends ExpressionManipulation
      invoke: (expression)->
        _ImplicitMultiplication.build(@comps).
          onNumeric(expression).
          append(@comps.build_pi())

    class_mixer(AppendPi)

    class AppendRoot extends ExpressionManipulation
      initialize: (opts={})->
        super
        @degree = opts.degree
      invoke: (expression)->
        degree = @comps.build_expression expression: [
            @comps.build_number(value: @degree)
          ]
        radicand = @comps.build_expression(expression: []).open()
        root = @comps.build_root(degree: degree, radicand: radicand)

        _ImplicitMultiplication.build(@comps).
          onNumeric(expression).
          append(root)
    class_mixer(AppendRoot)

    class AppendVariable extends ExpressionManipulation
      initialize: (opts={})->
        super
        @variable_name = opts.variable
      invoke: (expression)->
        variable = @comps.build_variable(name: @variable_name)
        _ImplicitMultiplication.build(@comps).
          onNumeric(expression).
          append(variable)


    class_mixer(AppendVariable)

    class SquareRoot extends ExpressionManipulation
      invoke: (expression)->
        value = @value(expression)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          num = @comps.build_number value: "#{root}"
          @comps.classes.expression.buildWithContent [num]
        else
          @comps.classes.expression.buildError()
    class_mixer(SquareRoot)

    class _ImplicitMultiplication
      initialize: (@comps)->
      onNumeric: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last instanceof @comps.classes.expression || last instanceof @comps.classes.pi)
          expression.append(@comps.build_multiplication())
        else
          expression

    class_mixer(_ImplicitMultiplication)

    class _OverrideIfOperatorOrAppend
      initialize: (@comps, @expression)->
      with: (operator)->
        last = @expression.last()
        if last && last.isOperator()
          if last instanceof @comps.classes.exponentiation
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

    class ExpressionManipulationSource
      initialize: (@comps)->
      classes: exports
    ttm.class_mixer(ExpressionManipulationSource)

    for name, klass of exports
      build_klass = do (name, klass)->
        (opts={})->
          opts.component_source = @comps
          klass.build(opts)
      ExpressionManipulationSource.prototype["build_#{name}"] = build_klass

    return ExpressionManipulationSource
