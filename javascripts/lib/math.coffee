#= require almond_wrapper
#= require lib
#= require lib/math/expression_components
#= require lib/math/buttons
#= require lib/math/expression_evaluation

ttm.define "lib/math",
  ["lib/class_mixer", 'lib/math/expression_components', 'lib/math/expression_evaluation'],
  (class_mixer, comps, expression_evaluation)->

    ##############
    # commands!
    ###############

    class Command
      evaluate: (exp)->
        expression_evaluation.build(exp).resultingExpression()

      value: (exp)->
        expression_evaluation.build(exp).resultingValue()

    class CalculateCommand extends Command
      invoke: (expression)->
        @evaluate(expression)
    class_mixer(CalculateCommand)

    class SquareCommand extends Command
      invoke: (expression)->
        val = @value(expression)
        comps.expression.build expression: [comps.number.build(value: val*val)]

    class_mixer(SquareCommand)

    class DecimalCommand
      invoke: (expression)->
        last = expression.last()
        if last instanceof comps.number
          new_last = last.clone()
          new_last.setFutureAsDecimal()
          expression.replaceLast(new_last)
        else
          new_last = comps.number.build(value: 0)
          new_last.setFutureAsDecimal()
          expression.append(new_last)
    class_mixer(DecimalCommand)

    class NumberCommand
      initialize: (@opts)->
        @val = @opts.value

      invoke: (expression)->
        expression = _ImplicitMultiplication.build().onNeitherOperatorNorNumber(expression)
        last = expression.last()
        if last && last.isNumber()
          new_last = last.concatenate(@val)
          expression.replaceLast(new_last)
        else
          new_last = comps.number.build(value: 0)
          expression.append(comps.number.build(value: @val))

    class_mixer(NumberCommand)

    class ExponentiationCommand
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.exponentiation.build()

    class_mixer(ExponentiationCommand)

    class MultiplicationCommand
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).with comps.multiplication.build()
    class_mixer(MultiplicationCommand)

    class AdditionCommand
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.addition.build()
    class_mixer(AdditionCommand)


    class SubtractionCommand
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.subtraction.build()
    class_mixer(SubtractionCommand)

    class NegationCommand
      invoke: (expression)->
        last = expression.last()
        if last
          expression.replaceLast(last.negated())
        else
          expression

    class_mixer(NegationCommand)

    class LeftParenthesisCommand
      invoke: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.left_parenthesis.build())

    class_mixer(LeftParenthesisCommand)

    class RightParenthesisCommand
      invoke: (expression)->
        expression.append(comps.right_parenthesis.build())
    class_mixer(RightParenthesisCommand)

    class DivisionCommand
      invoke: (expression)->
        _OverrideIfOperatorOrAppend.build(expression).
          with comps.division.build()
    class_mixer(DivisionCommand)


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

    class PiCommand
      invoke: (expression)->
        _ImplicitMultiplication.build().
          onNumeric(expression).
          append(comps.pi.build())

    class_mixer(PiCommand)

    class SquareRootCommand extends Command
      invoke: (expression)->
        value = @value(expression)
        root = Math.sqrt(parseFloat(value))
        unless isNaN(root)
          num = comps.number.build value: "#{root}"
          comps.expression.buildWithContent [num]
        else
          comps.expression.buildError()
    class_mixer(SquareRootCommand)


    exports =
      equation: comps.equation
      expression: comps.expression
      components: comps
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



