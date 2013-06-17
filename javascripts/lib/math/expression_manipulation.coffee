#= require almond_wrapper
#= require lib/math/expression_evaluation
#= require lib/math/expression_traversal

ttm.define "lib/math/expression_manipulation",
  ["lib/class_mixer",
    'lib/math/expression_evaluation', 'lib/object_refinement'],
  (class_mixer, expression_evaluation, object_refinement)->

    class ExpressionManipulation
      initialize: (opts={})->
        @comps = opts.comps
        @pos = opts.pos
      evaluate: (exp)->
        expression_evaluation.build(exp).resultingExpression()

      value: (exp)->
        result = expression_evaluation.build(exp).evaluate()
        if result then result.value() else 0

    class Calculate extends ExpressionManipulation
      perform: (expression)->
        @evaluate(expression)
    class_mixer(Calculate)

    class Square extends ExpressionManipulation
      perform: (expression)->
        val = @value(expression)
        @comps.build_expression expression: [@comps.build_number(value: val*val)]
    class_mixer(Square)

    class AppendDecimal extends ExpressionManipulation

      onFinalExpression: (expression)->
        last = expression.last()
        if last instanceof @comps.classes.number
          new_last = last.clone()
          new_last = new_last.futureAsDecimal()
          new_exp = expression.replaceLast(new_last)
        else
          new_last = @comps.build_number(value: 0)
          new_last = new_last.futureAsDecimal()
          new_exp = expression.append(new_last)
        @pointer = @pos.build(new_exp.last().id())
        new_exp

      perform: (expression)->
        resulting_expression =
          _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
            performOrDefault((expr)=> @onFinalExpression(expr))

        expression: resulting_expression
        position: @pointer


    class_mixer(AppendDecimal)

    class AppendNumber extends ExpressionManipulation
      initialize: (opts={})->
        super
        @val = opts.value
      # doAppend: (expression)->
      #   last = expression.last()
      #   number_to_append = @comps.build_number(value: @val)

      #   if last && last instanceof @comps.classes.number
      #     new_last = last.concatenate(@val)
      #     new_exp = expression.replaceLast(new_last)
      #   else if (last && last instanceof @comps.classes.exponentiation) or (last && !last.isOperator())
      #     new_exp = expression.append(@comps.build_multiplication()).
      #       append(number_to_append)
      #   else
      #     new_exp = expression.append(number_to_append)

      #   @pointer = @pos.build(position: new_exp.id())
      #   new_exp

      # @destructive
      doAppendD: (expression, expression_position)->
        number_to_append = @comps.build_number(value: @val)
        last = expression.last()
        if last
          if last instanceof @comps.classes.number
            expression.last().concatenateD(@val)
          else if (last instanceof @comps.classes.exponentiation) or !last.isOperator()
            expression.appendD(@comps.build_multiplication())
            expression.appendD(number_to_append)
          else
            expression.appendD(number_to_append)
        else
          expression.appendD(number_to_append)

      perform: (expression_position)->
        result_exp = _ExpressionManipulator.build(expression_position.expression()).clone().
          withComponent(expression_position, (component)=>
            @doAppendD(component, expression_position)
          ).value()

        # would be same position, but a new expression
        expression_position.clone(expression: result_exp)

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

      perform: (expression)->
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

    class AppendExponentiation extends ExpressionManipulation
      perform: (expression_position)->
        base = @comps.build_expression()
        power = @comps.build_expression()

        result_exp = _ExpressionManipulator.build(expression_position.expression()).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(@comps.build_exponentiation(base: base, power: power))
          ).value()

        # would be same position, but a new expression
        expression_position.clone(expression: result_exp)

    class_mixer(AppendExponentiation)

    class AppendMultiplication extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = _ExpressionManipulator.build(expr).clone().
          withComponent(expression_position, (component)=>
            _OverrideIfOperatorOrAppend.build(@comps, component).withD(
              @comps.build_multiplication()
            )
          ).value()

        expression_position.clone(expression: result_exp)

    class_mixer(AppendMultiplication)

    class AppendEquals extends ExpressionManipulation
      perform: (expression)->
        expression.append @comps.build_equals()
    class_mixer(AppendEquals)

    class AppendDivision extends ExpressionManipulation
      perform: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          performOrDefault((expr)=>
            _OverrideIfOperatorOrAppend.build(@comps, expr).with @comps.build_division())
    class_mixer(AppendDivision)


    class AppendAddition extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = _ExpressionManipulator.build(expr).clone().
          withComponent(expression_position, (component)=>
            _OverrideIfOperatorOrAppend.build(@comps, component).withD(@comps.build_addition())
          ).value()

        expression_position.clone(expression: result_exp)

    class_mixer(AppendAddition)

    class AppendSubtraction extends ExpressionManipulation
      perform: (expression)->
        _FinalOpenSubExpressionApplication.build(expr: expression, comps: @comps).
          performOrDefault((expression)=>
            _OverrideIfOperatorOrAppend.build(@comps, expression).with @comps.build_subtraction())
    class_mixer(AppendSubtraction)

    class Negation extends ExpressionManipulation
      perform: (expression)->
        last = expression.last()
        if last
            expression.replaceLast(last.negated())
        else
          expression

    class_mixer(Negation)

    class AppendOpenSubExpression extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        new_exp = @comps.build_expression().open()

        result_exp = _ExpressionManipulator.build(expr).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).
              invoke(component).
              appendD(new_exp)
          ).value()

        expression_position.clone(expression: result_exp, position: new_exp.id())

    class_mixer(AppendOpenSubExpression)

    class CloseSubExpression extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        result_exp = _ExpressionManipulator.build(expr).clone().
          withComponent(expression_position, (component)=>
            component.closeD()
            parent = component.parent()
            @position_id = if parent then parent.id() else component.id()
          ).value()
        expression_position.clone(expression: result_exp, position: @position_id)
    class_mixer(CloseSubExpression)

    # TODO this needs to ahve final open sub expression application
    class AppendPi extends ExpressionManipulation
      perform: (expression)->
        _ImplicitMultiplication.build(@comps).
          invoke(expression).
          append(@comps.build_pi())

    class_mixer(AppendPi)

    class AppendRoot extends ExpressionManipulation
      initialize: (opts={})->
        super
        @degree = opts.degree

      perform: (expression_position)->
        degree =
          if @degree
            @comps.build_expression expression: [
              @comps.build_number(value: @degree)
            ]
          else
            @comps.build_expression()
        radicand = @comps.build_expression(expression: [])
        root = @comps.build_root(degree: degree, radicand: radicand)

        result_exp = _ExpressionManipulator.build(expression_position.expression()).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(root)
          ).value()

        # would be same position, but a new expression
        expression_position.clone(expression: result_exp)

    class_mixer(AppendRoot)

    class AppendVariable extends ExpressionManipulation
      initialize: (opts={})->
        super
        @variable_name = opts.variable
      perform: (expression)->
        variable = @comps.build_variable(name: @variable_name)
        _ImplicitMultiplication.build(@comps).
          invoke(expression).
          append(variable)


    class_mixer(AppendVariable)

    class SquareRoot extends ExpressionManipulation
      perform: (expression)->
        value = @value(expression)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          num = @comps.build_number value: "#{root}"
          @comps.classes.expression.buildWithContent [num]
        else
          @comps.classes.expression.buildError()
    class_mixer(SquareRoot)


    class Reset extends ExpressionManipulation
      perform:  (expression, position)->
        empty_expression = @comps.build_expression(expression: [])
        @pos.build(expression: empty_expression, position: empty_expression.id())
    class_mixer(Reset)

    class UpdatePosition extends ExpressionManipulation
      initialize: (opts={})->
        super
        @new_position_element_id = opts.element_id
        @new_position_element_type = opts.type

      perform:  (expression_position)->
        expression_position.clone(position: @new_position_element_id, type: @new_position_element_type)

    class_mixer(UpdatePosition)


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

      perform: (@action)->
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

      performOrDefault: (@action)->
        result = @findAndPerformAction(@expr)
        if @wasFound()
          result
        else
          @action(@expr)

    class_mixer(_FinalOpenSubExpressionApplication)


    class _ImplicitMultiplication
      initialize: (@comps)->
      invoke: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last instanceof @comps.classes.expression || last instanceof @comps.classes.pi)
          expression.append(@comps.build_multiplication())
        else
          expression

      invokeD: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last instanceof @comps.classes.expression || last instanceof @comps.classes.pi)
          expression.appendD(@comps.build_multiplication())
          expression
        else
          expression

    class_mixer(_ImplicitMultiplication)

    class _OverrideIfOperatorOrAppend
      initialize: (@comps, @expression)->
      with: (operator, append_method="append", replace_method="replaceLast")->
        last = @expression.last()

        action =
          if last
            if last.isOperator()
              if last instanceof @comps.classes.exponentiation
                "append"
              else
                "replace"
            else
              "append"
          else
            "append"

        if action == "append"
          @expression[append_method](operator)
        else if action == "replace"
          @expression[replace_method](operator)

      # @destructive
      withD: (operator)->
        @with(operator, "appendD", "replaceLastD")

    class_mixer(_OverrideIfOperatorOrAppend)


    class _TrailingOperatorHandling
      initialize: (@expression)->

      getSubexpression: ->
        last = @expression.last()
        last.preceedingSubexpression()

    class_mixer(_TrailingOperatorHandling)

    class _ExpressionManipulator
      initialize: (@expr)->
      clone: ->
        @expr = @expr.clone()
        @
      withComponent: (position, fn)->
        comp = ttm.lib.math.ExpressionTraversal.build(@expr).
          findForID(position.position())
        fn(comp)
        @

      value: -> @expr

    class_mixer(_ExpressionManipulator)

    exports =
      calculate: Calculate
      square: Square
      append_decimal: AppendDecimal
      append_number: AppendNumber
      exponentiate_last: ExponentiateLast
      append_exponentiation: AppendExponentiation
      append_multiplication: AppendMultiplication
      append_addition: AppendAddition
      append_equals: AppendEquals
      append_subtraction: AppendSubtraction
      negate_last: Negation
      append_open_sub_expression: AppendOpenSubExpression
      close_sub_expression: CloseSubExpression
      append_division: AppendDivision
      append_pi: AppendPi
      update_position: UpdatePosition
      square_root: SquareRoot
      append_root: AppendRoot
      append_variable: AppendVariable
      reset: Reset

    class ExpressionManipulationSource
      initialize: (@comps, @pos)->
      classes: exports
    ttm.class_mixer(ExpressionManipulationSource)

    for name, klass of exports
      build_klass = do (name, klass)->
        (opts={})->
          opts.comps = @comps
          opts.pos = @pos
          klass.build(opts)
      ExpressionManipulationSource.prototype["build_#{name}"] = build_klass

    return ExpressionManipulationSource
