#= require lib/math/expression_evaluation
#= require lib/math/expression_traversal
#= require ./base


ttm.define "lib/math/expression_manipulation",
  ["lib/class_mixer",
    'lib/math/expression_evaluation', 'lib/object_refinement'],
  (class_mixer, expression_evaluation, object_refinement)->

    # First, the utilities that most of these classes link to

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
      invokeD: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last.isExpression() || last.isVariable() || last.isFraction() || last.isExponentiation() || last.isRoot() )
          expression.appendD(@comps.build_multiplication())
          expression
        else
          expression

    class_mixer(_ImplicitMultiplication)

    class _ExpressionManipulator
      initialize: (@expr, @traversal)->
      clone: ->
        @expr = @expr.clone()
        @
      withComponent: (position, fn)->
        comp = @traversal.build(@expr).
          findForID(position.position())
        fn(comp)
        @
      value: -> @expr

    class_mixer(_ExpressionManipulator)



    # next, the manipulations themselves

    class ExpressionManipulation
      initialize: (opts={})->
        @comps = opts.comps
        @pos = opts.pos
        @traversal = opts.traversal

      evaluate: (exp)->
        ret = expression_evaluation.build(exp).resultingExpression()
      value: (exp)->
        result = expression_evaluation.build(exp).evaluate()
        if result then result.value() else 0

      M: (@expr)->
        _ExpressionManipulator.build(@expr, @traversal)

      isOperator: (comp)->
        c = @comps.classes
        # for these manipulations do we consider the comp to be an operator
        switch comp.klass
          when c.equals, c.addition, c.subtraction, c.multiplication, c.division
            true
          else false

      # @destructive
      withoutTrailingOperatorD: (exp)->
        if @isOperator(exp.last())
          exp.withoutLastD()
        exp

    class ExpressionPositionManipulator
      initialize: (@traversal)->

      # Calls callback on each node in exp_pos
      # The first time callback returns true, it
      # returns an updated exp_pos pointing at that node
      updatePositionTo: (exp_pos, callback)->
        exp_pos = exp_pos.clone()
        found = false
        new_pos_id = false
        @traversal.build(exp_pos).each (comp)=>
          if !found
            cb_results = callback(comp)
            if cb_results
              new_pos_id = comp.id()
              found = true
        exp_pos.clone(position: new_pos_id)

    class_mixer(ExpressionPositionManipulator)

    class Calculate extends ExpressionManipulation
      perform: (expression_position)->
        results = @evaluate(expression_position.expression())
        expression_position.clone(expression: results, position: results.id())

    class_mixer(Calculate)

    class Square extends ExpressionManipulation
      perform: (expression_position)->
        val = @value(expression_position.expression())
        new_exp = @comps.build_expression expression: [@comps.build_number(value: val*val)]
        @pos.build(expression: new_exp, position: new_exp.id())

    class_mixer(Square)

    class AppendDecimal extends ExpressionManipulation
      # @destructive
      doAppendD: (expression, expression_position)->
        last = expression.last()
        if last
          if last.isNumber()
            last.futureAsDecimalD(true)
          else
            _ImplicitMultiplication.build(@comps).invokeD(expression)
            new_last = @comps.build_number(value: 0)
            new_last.futureAsDecimalD(true)
            expression.appendD(new_last)
        else
          new_last = @comps.build_number(value: 0)
          new_last.futureAsDecimalD(true)
          expression.appendD(new_last)


      perform: (expression_position)->
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @doAppendD(component, expression_position)
          ).value()
        result_exp

    class_mixer(AppendDecimal)

    class AppendNumber extends ExpressionManipulation
      initialize: (opts={})->
        super
        @val = opts.value

      # @destructive
      doAppendD: (append_to, expression_position)->
        number_to_append = @comps.build_number(value: @val)
        last = append_to.last()
        if last
          if last instanceof @comps.classes.number
            append_to.last().concatenateD(@val)
          else if (last instanceof @comps.classes.exponentiation) or !@isOperator(last)
            append_to.appendD(@comps.build_multiplication())
            append_to.appendD(number_to_append)
          else
            append_to.appendD(number_to_append)
        else
          append_to.appendD(number_to_append)

      perform: (expression_position)->
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @doAppendD(component, expression_position)
          ).value()

        result_exp

    class_mixer(AppendNumber)

    class ExponentiateLast extends ExpressionManipulation
      initialize: (opts={})->
        super
        @power = opts.power

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

        power

      exponentiateLastOfComponent: (component)->
        return if component.isEmpty()
        last = component.last()

        # in the first case, our base case comes
        # from the contents of a previous part of the expression
        if it = last.preceedingSubexpression()
          base = @baseExpression(it)

        # if the previous element is an operator but has no sub-expression,
        # then we are dropping the operator and use the number prior to the operator
        else if @isOperator(last)
          component.withoutLastD() #remove useless operator
          base = @baseExpression(component.last())

        # otherwise, our base is just the number before
        else
          base = @baseExpression(component.last())

        power = @powerExpression()

        @pos_id = @posID(power, component)
        component.replaceLastD(@comps.build_exponentiation(base: base, power: power))

      posID: (power, component)->
        power.id()


      perform: (expression_position)->
        expression = expression_position.expression()
        return expression_position if expression.isEmpty()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @exponentiateLastOfComponent(component)
          ).value()

        result_exp.clone position: @pos_id

    class_mixer(ExponentiateLast)

    class AppendExponentiation extends ExpressionManipulation
      initialize: (opts={})->
        super
        @exponent_content = opts.power

      perform: (expression_position)->
        exp = if @exponent_content
          [@comps.build_number(value: @exponent_content)]
        else
          []

        base = @comps.build_expression()
        power = @comps.build_expression(expression: exp)
        exponentiation = @comps.build_exponentiation(base: base, power: power)

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(exponentiation)
          ).value()

        result_exp.clone(position: base.id())

    class_mixer(AppendExponentiation)

    class AppendMultiplication extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(@comps.build_multiplication())
          ).value()

        result_exp

    class_mixer(AppendMultiplication)

    class AppendEquals extends ExpressionManipulation
      perform: (expression_position)->
        # appending an equals moves the cursor to after the equals sign
        # so update to that position
        expression_position = expression_position.clone(position: expression_position.expression().id())
        equals = @comps.build_equals()
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(equals)
          ).value()

        result_exp
    class_mixer(AppendEquals)

    class AppendDivision extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(@comps.build_division())
          ).value()


        result_exp
    class_mixer(AppendDivision)


    class AppendAddition extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(@comps.build_addition())
          ).value()

        result_exp

    class_mixer(AppendAddition)

    class AppendSubtraction extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(@comps.build_subtraction())
          ).value()
        result_exp

    class_mixer(AppendSubtraction)


    class AppendDivision extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        return expression_position if expr.isEmpty()

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @withoutTrailingOperatorD(component).appendD(@comps.build_division())
          ).value()

        result_exp
    class_mixer(AppendDivision)

    class NegateLast extends ExpressionManipulation
      negateComp: (comp)->
        last = comp.last()

        if last instanceof @comps.classes.number
          last.negatedD()

      perform: (expression_position)->
        expr = expression_position.expression()
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            @negateComp(component)
          ).value()
        result_exp

    class_mixer(NegateLast)

    class AppendSubExpression extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        new_exp = @comps.build_expression()
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(new_exp)
          ).value()
        result_exp.clone position: new_exp.id()

    class_mixer(AppendSubExpression)

    class ExitSubExpression extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            parent = component.parent()
            if parent # do we have a parent?
              if parent.isExpression() # parent might not be an expression
                @position_id = parent.id() # if so, this is what we want
              else # parent was not an expression, grandparent must be an expression
                @position_id = parent.parent().id()
            else
              @position_id = component.id()
          ).value()
        result_exp.clone position: @position_id
    class_mixer(ExitSubExpression)

    class AppendPi extends ExpressionManipulation
      initialize: (opts={})->
        super
        @pi_value = opts.value
      perform: (expression_position)->
        expr = expression_position.expression()
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(@comps.build_pi(value: @pi_value))
          ).value()
        result_exp

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

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(root)
          ).value()

        result_exp.clone position: radicand.id()

    class_mixer(AppendRoot)

    class AppendVariable extends ExpressionManipulation
      initialize: (opts={})->
        super
        @variable_name = opts.variable

      perform: (expression_position)->
        expr = expression_position.expression()

        variable = @comps.build_variable(name: @variable_name)

        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(variable)
          ).value()
        result_exp

    class_mixer(AppendVariable)


    class AppendFraction extends ExpressionManipulation
      perform: (expression_position)->
        exp = expression_position.expression()

        numerator = @comps.build_expression()
        denominator = @comps.build_expression()
        fraction = @comps.build_fraction(numerator: numerator, denominator: denominator)
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(fraction)
          ).value()

        result_exp.clone position: numerator.id()

    class_mixer(AppendFraction)

    class AppendFn extends ExpressionManipulation
      initialize: (opts={})->
        super
        @name = opts.name

      perform: (expression_position)->
        exp = expression_position.expression()

        argument = @comps.build_expression()
        fn = @comps.build_fn(name: @name, argument: argument)
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            _ImplicitMultiplication.build(@comps).invokeD(component)
            component.appendD(fn)
          ).value()

        result_exp

    class_mixer(AppendFn)

    class SquareRoot extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression()
        value = @value(expr)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          expr = @comps.build_expression expression: [@comps.build_number(value: "#{root}")]
          @pos.build(expression: expr, position: expr.id())
        else
          expr = expr.clone(is_error: true)
          @pos.build(expression: expr, position: expr.id())


    class_mixer(SquareRoot)

    class Reset extends ExpressionManipulation
      perform:  (expression_position)->
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


    class SubstituteVariables extends ExpressionManipulation
      initialize: (opts={})->
        super
        @variables = opts.variables
      perform: (expression_position)->
        exp_pos = expression_position.clone()
        @traversal.build(exp_pos).each (comp)=>
          if comp instanceof @comps.classes.variable
            if @isThisVariable(comp.name())
              number = @comps.build_number(value: @variableValue(comp.name()))
              comp.parent().replaceD(comp, number)

        exp_pos

      isThisVariable: (variable_name)->
        for variable in @variables
          return true if variable.name == variable_name

      variableValue: (variable_name)->
        for variable in @variables
          if variable.name == variable_name
            return variable.value

    class_mixer(SubstituteVariables)


    class GetLeftSide extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression().clone()
        expr.expression.splice(@indexOfEquals(expr.expression), expr.expression.length)
        expression_position.clone(expression: expr)

      # find index of
      indexOfEquals: (expression)->
        for index, exp of expression
          return (index*1) if exp instanceof @comps.classes.equals
    class_mixer(GetLeftSide)


    class GetRightSide extends ExpressionManipulation
      perform: (expression_position)->
        expr = expression_position.expression().clone()
        expr.expression.splice(0, @indexOfEquals(expr.expression)+1)
        expression_position.clone(expression: expr)

      # find index of
      indexOfEquals: (expression)->
        for index, exp of expression
          return (index*1) if exp instanceof @comps.classes.equals
    class_mixer(GetRightSide)

    class RemovePointedAt extends ExpressionManipulation
      perform: (expression_position)->
        result_exp = @M(expression_position).clone().
          withComponent(expression_position, (component)=>
            component.withoutLastD()
          ).value()
        result_exp

    class_mixer(RemovePointedAt)

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
      negate_last: NegateLast
      append_sub_expression: AppendSubExpression
      exit_sub_expression: ExitSubExpression
      append_division: AppendDivision
      append_pi: AppendPi
      update_position: UpdatePosition
      square_root: SquareRoot
      append_root: AppendRoot
      append_variable: AppendVariable
      reset: Reset
      substitute_variables: SubstituteVariables
      get_left_side: GetLeftSide
      get_right_side: GetRightSide
      append_fraction: AppendFraction
      append_fn: AppendFn
      remove_pointed_at: RemovePointedAt

    class ExpressionManipulationSource
      initialize: (@comps, @pos, @traversal)->
        @utils = {}
        @utils.build_expression_position_manipulator = =>
          ExpressionPositionManipulator.build(@traversal)
      classes: exports
    ttm.class_mixer(ExpressionManipulationSource)

    for name, klass of exports
      build_klass = do (name, klass)->
        (opts={})->
          opts.comps = @comps
          opts.pos = @pos
          opts.traversal = @traversal
          klass.build(opts)
      ExpressionManipulationSource.prototype["build_#{name}"] = build_klass

    window.ttm.lib.math.ExpressionManipulationSource = ExpressionManipulationSource

    return ExpressionManipulationSource
