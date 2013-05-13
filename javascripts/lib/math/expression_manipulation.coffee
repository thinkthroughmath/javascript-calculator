#= require almond_wrapper
#= require lib/math/expression_evaluation

ttm.define "lib/math/expression_manipulation",
  ["lib/class_mixer", 'lib/math/expression_components',
    'lib/math/expression_evaluation'],
  (class_mixer, comps, expression_evaluation)->

    class ExpressionManipulation
      evaluate: (exp)->
        expression_evaluation.build(exp).resultingExpression()

      value: (exp)->
        expression_evaluation.build(exp).resultingValue()

    class CalculateExpressionManipulation extends ExpressionManipulation
      invoke: (expression)->
        @evaluate(expression)
    class_mixer(CalculateExpressionManipulation)

    class SquareExpressionManipulation extends ExpressionManipulation
      invoke: (expression)->
        val = @value(expression)
        comps.expression.build expression: [comps.number.build(value: val*val)]

    class_mixer(SquareExpressionManipulation)

    class DecimalExpressionManipulation
      invoke: (expression)->
        last = expression.last()
        if last instanceof comps.number
          new_last = last.clone()
          new_last = new_last.futureAsDecimal()
          expression.replaceLast(new_last)
        else
          new_last = comps.number.build(value: 0)
          new_last = new_last.futureAsDecimal()
          expression.append(new_last)
    class_mixer(DecimalExpressionManipulation)

    class AddNumberToEndExpressionManipulation
      initialize: (@opts)->
        @val = @opts.value

      invoke: (expression)->
        expression = _ImplicitMultiplication.build().onNeitherOperatorNorNumber(expression)
        last = expression.last()
        number_with_this_val = comps.number.build(value: @val)
        if last && last instanceof comps.number
          new_last = last.concatenate(@val)
          expression.replaceLast(new_last)
        else if last && last instanceof comps.exponentiation
          power = last.power()
          if power instanceof comps.blank
            new_last = last.updatePower(number_with_this_val)
          else
            new_last = last.updatePower(power.concatenate(@val))
          expression.replaceLast(new_last)
        else
          expression.append(number_with_this_val)

    class_mixer(AddNumberToEndExpressionManipulation)

    class ExponentiateLastExpressionManipulation
      baseForExponent: (expression)->
        last = expression.last()
        last
      invoke: (expression)->
        [expression, subexpression] = _TrailingOperatorHandling.build(expression).remove()
        base = subexpression || @baseForExponent(expression)
        expression.replaceLast(comps.exponentiation.build(base: base, power: comps.blank.build()))

    class_mixer(ExponentiateLastExpressionManipulation)

    class MultiplicationExpressionManipulation
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).with comps.multiplication.build()
    class_mixer(MultiplicationExpressionManipulation)

    class AdditionExpressionManipulation
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.addition.build()
    class_mixer(AdditionExpressionManipulation)


    class SubtractionExpressionManipulation
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.subtraction.build()
    class_mixer(SubtractionExpressionManipulation)

    class NegationExpressionManipulation
      invoke: (expression)->
        last = expression.last()
        if last
            expression.replaceLast(last.negated())
        else
          expression

    class_mixer(NegationExpressionManipulation)

    class LeftParenthesisExpressionManipulation
      invoke: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.left_parenthesis.build())

    class_mixer(LeftParenthesisExpressionManipulation)

    class RightParenthesisExpressionManipulation
      invoke: (expression)->
        expression.append(comps.right_parenthesis.build())
    class_mixer(RightParenthesisExpressionManipulation)

    class DivisionExpressionManipulation
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.division.build()
    class_mixer(DivisionExpressionManipulation)



    class PiExpressionManipulation
      invoke: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.pi.build())

    class_mixer(PiExpressionManipulation)

    class SquareRootExpressionManipulation extends ExpressionManipulation
      invoke: (expression)->
        value = @value(expression)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          num = comps.number.build value: "#{root}"
          comps.expression.buildWithContent [num]
        else
          comps.expression.buildError()
    class_mixer(SquareRootExpressionManipulation)


    class _ImplicitMultiplication
      onNumeric: (expression)->
        last = expression.last()
        if last && (last.isNumber() || last instanceof comps.right_parenthesis || last instanceof comps.pi)
          expression.append(comps.multiplication.build())
        else
          expression

      onNeitherOperatorNorNumber: (expression)->
        last = expression.last()
        if last and !last.isNumber()  and !last.isOperator() and !(last instanceof comps.left_parenthesis)
          expression.append(comps.multiplication.build())
        else
          expression

    class_mixer(_ImplicitMultiplication)

    class _OverrideIfOperatorOrAppend
      initialize: (@expression)->
      with: (operator)->
        last = @expression.last()
        if last && last.isOperator()
          @expression.replaceLast(operator)
        else
          @expression.append(operator)
    class_mixer(_OverrideIfOperatorOrAppend)


    class _TrailingOperatorHandling
      initialize: (@expression)->
      remove: ->
        last = @expression.last()
        if last && last.isOperator()
          preceeding = last.preceedingSubexpression()
          without_last = @expression.withoutLast()
          [without_last, preceeding]
        else
          [@expression, null]
    class_mixer(_TrailingOperatorHandling)

    exports =
      calculate: CalculateExpressionManipulation
      square: SquareExpressionManipulation
      decimal: DecimalExpressionManipulation
      add_number_to_end: AddNumberToEndExpressionManipulation
      exponentiate_last: ExponentiateLastExpressionManipulation
      multiplication: MultiplicationExpressionManipulation
      addition: AdditionExpressionManipulation
      subtraction: SubtractionExpressionManipulation
      negate_last: NegationExpressionManipulation
      left_parenthesis: LeftParenthesisExpressionManipulation
      right_parenthesis: RightParenthesisExpressionManipulation
      division: DivisionExpressionManipulation
      pi: PiExpressionManipulation
      square_root: SquareRootExpressionManipulation

    return exports
