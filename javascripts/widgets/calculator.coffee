class Calculator
  @open_widget_dialog: (element)->
    if element.empty()
      Calculator.build_widget(element)
    element.dialog(dialogClass: "calculator-dialog", title: "Calculator")
    element.dialog("open")

  @build_widget: (element)->
    logic = Calculator.LogicController.build(Calculator.Expression)
    button_builder = ButtonBuilder.build()
    spacer = Calculator.SpacerButton.build
      button_builder: button_builder

    nums0to9 = Calculator.NumberButton.build0to9
      logic: logic
      button_builder: button_builder
      number_builder: Number

    addition = Calculator.AdditionButton.build
      logic: logic
      button_builder: button_builder
      addition_builder: Addition

    multiplication = Calculator.MultiplicationButton.build
      logic: logic
      button_builder: button_builder
      multiplication_builder: Multiplication

    division = Calculator.DivisionButton.build
      logic: logic
      button_builder: button_builder
      division_builder: Division

    subtraction = Calculator.SubtractionButton.build
      logic: logic
      button_builder: button_builder

    clear = Calculator.ClearButton.build
      logic: logic
      button_builder: button_builder

    negative = Calculator.NegativeButton.build
      logic: logic
      button_builder: button_builder
      negative_builder: Negative

    equals = Calculator.EqualsButton.build
      logic: logic
      button_builder: button_builder

    decimal = Calculator.DecimalButton.build
      logic: logic
      button_builder: button_builder
      decimal_builder: Decimal

    square = Calculator.SquareButton.build
      logic: logic
      button_builder: button_builder
      square_builder: Square

    square_root = Calculator.SquareRootButton.build
      logic: logic
      button_builder: button_builder
      square_root_builder: SquareRoot

    exponent = Calculator.ExponentButton.build
      logic: logic
      button_builder: button_builder
      exponent_builder: Exponent

    lparen = Calculator.LeftParenthesisButton.build
      logic: logic
      button_builder: button_builder
      left_parenthesis_builder: LeftParenthesis

    rparen = Calculator.RightParenthesisButton.build
      logic: logic
      button_builder: button_builder
      right_parenthesis_builder: RightParenthesis

    pi = Calculator.PiButton.build
      logic: logic
      button_builder: button_builder
      pi_builder: Pi

    layout = ButtonLayout.build
      numbers: nums0to9
      addition: addition
      equals: equals
      subtraction: subtraction
      multiplication: multiplication
      spacer: spacer
      clear: clear
      decimal: decimal
      negative: negative
      square: square
      square_root: square_root
      lparen: lparen
      rparen: rparen
      pi: pi
      division: division
      exponent: exponent

    Calculator.build(element, logic, layout)

  initialize: (@element, @calc_logic, @component_layout)->
    @render()
    @calc_logic.onResultChange ((new_val)=> @display(new_val))

  display: (content)->
    @element.find("figure.calculator-display").html(content)

  render: ->
    @element.append """
      <div class='calculator'>
        <figure class='calculator-display'>0</figure>
      </div>
    """
    calc_div = @element.find('div.calculator')
    @component_layout.render(calc_div)

window.ttm.Calculator = ttm.ClassMixer(Calculator)

class ButtonLayout
  initialize: ((@components)->)
  render: (@element)->

    @render_components ["square", "square_root", "exponent", "clear"]

    @render_components ["pi", "lparen", "rparen", "division"]

    @render_numbers [7..9]
    @render_component "multiplication"

    @render_numbers [4..6]
    @render_component "subtraction"

    @render_numbers [1..3]
    @render_component "addition"

    @render_numbers [0]
    @render_components ["decimal", "negative", "equals"]

  render_numbers: (nums)->
    for num in nums
      @components.numbers[num].renderButton(@element)

  render_component: (comp)->
    if @components[comp]
      @components[comp].renderButton @element
    else
      @components.spacer.renderButton @element

  render_components: (components)->
    for comp in components
      @render_component comp

window.ttm.Calculator.ButtonLayout = ttm.ClassMixer(ButtonLayout)

class LogicController
  initialize: (@expression_builder)->
    @current_expression = @expression_builder.build()

  onResultChange: ((@handler)->)

  display: ->
    if @handler
      val = @current_expression.display()
      if val.length == 0
        @handler('0')
      else
        @handler(val)

  calculate: ->
    @current_expression.calculate()
    @display()

  msg: (part)->
    if part.invoke
      part.invoke(@current_expression)
    else
      @current_expression.msg(part)
    @display()

  reset: ->
    @current_expression.reset()
    @display()

  buttonPressed: (component)->
    component.action(@current_expression)
    @display()

window.ttm.Calculator.LogicController = ttm.ClassMixer(LogicController)

class ButtonBuilder
  buildButton: (opts={})->
    button = $("<button class='#{opts.class}' value='#{opts.value}'>#{opts.label || opts.value}</button>")
    button.click ->
      opts.target.clicked()
    opts.element.append button

window.ttm.Calculator.ButtonBuilder = ttm.ClassMixer(ButtonBuilder)

class SpacerButton
  initialize: ((@opts)->)

  clicked: ->
    alert "button does nothing!"

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: "(n/a)"
      target: @
      class: 'other'

window.ttm.Calculator.SpacerButton = ttm.ClassMixer(SpacerButton)

class NumberButton
  @build0to9: (opts)->
    for i in [0..9]
      NumberButton.build(_.extend({digit: i}, opts))

  initialize: ((@opts)->)

  clicked: ->
    @opts.logic.msg(@opts.number_builder.build(value: @opts.digit))

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: @opts.digit
      target: @
      class: 'number-specifier'

window.ttm.Calculator.NumberButton = ttm.ClassMixer(NumberButton)


class AdditionButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '+'
      target: @
      class: 'operation'

  clicked: ->
    @opts.logic.msg(@opts.addition_builder.build())

window.ttm.Calculator.AdditionButton = ttm.ClassMixer(AdditionButton)

class MultiplicationButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '*'
      label: '&times;'
      target: @
      class: 'operation'

  clicked: ->
    @opts.logic.msg(@opts.multiplication_builder.build())

window.ttm.Calculator.MultiplicationButton = ttm.ClassMixer(MultiplicationButton)

class DivisionButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '/'
      label: '&divide;'
      target: @
      class: 'operation'

  clicked: ->
    @opts.logic.msg(@opts.division_builder.build())

window.ttm.Calculator.DivisionButton = ttm.ClassMixer(DivisionButton)


class SubtractionButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '-'
      target: @
      class: 'operation'

  clicked: ->
    @opts.logic.msg(Subtraction.build())

window.ttm.Calculator.SubtractionButton = ttm.ClassMixer(SubtractionButton)


class NegativeButton
  initialize: (@opts)->
  clicked: ->
    @opts.logic.msg @opts.negative_builder.build()

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: 'negative'
      label: '(-)'
      target: @
      class: 'number-specifier'

window.ttm.Calculator.NegativeButton = ttm.ClassMixer(NegativeButton)


class EqualsButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '='
      target: @
      class: 'operation'

  clicked: ->
    @opts.logic.calculate()

window.ttm.Calculator.EqualsButton = ttm.ClassMixer(EqualsButton)


class ClearButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: 'clear'
      target: @
      class: 'other clear'

  clicked: ->
    @opts.logic.reset()

window.ttm.Calculator.ClearButton = ttm.ClassMixer(ClearButton)

class SquareButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: 'square'
      label: 'x<sup>2</sup>'
      class: 'other square'
      target: @

  clicked: ->
    @opts.logic.msg(@opts.square_builder.build())

window.ttm.Calculator.SquareButton = ttm.ClassMixer(SquareButton)



class SquareRootButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: 'squareroot'
      label: '&radic;<span>&#8212;</span>'
      class: 'other square-root'
      target: @

  clicked: ->
    @opts.logic.msg(@opts.square_root_builder.build())

window.ttm.Calculator.SquareRootButton = ttm.ClassMixer(SquareRootButton)

class ExponentButton
  initialize: ((@opts)->)
  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '^'
      target: @
      class: 'other'
  clicked: ->
    @opts.logic.msg(@opts.exponent_builder.build())

window.ttm.Calculator.ExponentButton = ttm.ClassMixer(ExponentButton)


class DecimalButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '.'
      target: @
      class: 'number-specifier'
  clicked: ->
    @opts.logic.msg(@opts.decimal_builder.build())

window.ttm.Calculator.DecimalButton = ttm.ClassMixer(DecimalButton)


class LeftParenthesisButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: '('
      target: @
      class: 'parentheses other'

  clicked: ->
    @opts.logic.msg(@opts.left_parenthesis_builder.build())

window.ttm.Calculator.LeftParenthesisButton = ttm.ClassMixer(LeftParenthesisButton)

class RightParenthesisButton
  initialize: ((@opts)->)

  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: ')'
      target: @
      class: 'parentheses other'

  clicked: ->
    @opts.logic.msg(@opts.right_parenthesis_builder.build())

window.ttm.Calculator.RightParenthesisButton = ttm.ClassMixer(RightParenthesisButton)

class PiButton
  initialize: ((@opts)->)
  renderButton: (element)->
    @opts.button_builder.buildButton
      element: element
      value: 'pi'
      label: '&pi;'
      target: @
      class: 'pi other'
  clicked: ->
    @opts.logic.msg(@opts.pi_builder.build())

window.ttm.Calculator.PiButton = ttm.ClassMixer(PiButton)


class Expression
  initialize: ->
    @reset()

  msg: (part)->
    @expression.push part

  # returns part of an expression
  last: ->
    _.last(@expression)

  reset: ->
    @expression = []

  calculate: ->
    evaled = @evaluate()
    @expression = [evaled]
    evaled

  set: (expression)->
    @expression = expression

  evaluate: ->
    (new ExpressionEvaluation @expression).results()

  display: ->
    ret = _(@expression).map((it)-> it.toDisplay()).join(' ')
    ret

window.ttm.Calculator.Expression = ttm.ClassMixer(Expression)


class ExpressionEvaluation
  constructor: (@expression)->
    expr = (new ExpressionEvaluationPass(@expression)).perform("parenthetical")
    expr = (new ExpressionEvaluationPass(expr)).perform("exponentiation")
    expr = (new ExpressionEvaluationPass(expr)).perform("multiplication")
    expr = (new ExpressionEvaluationPass(expr)).perform("addition")
    @eval_results = _(expr).first()

  results: ->
    @eval_results

class ExpressionEvaluationPass
  constructor: (@expression)->
    @expression_index = -1
    
  perform: (pass_type)->
    processed = for exp in @expression
      @expression_index += 1
      if exp.isHandled()
        exp
      else
        exp.eval(@, pass_type)
    _(processed).reject (it)->
      it.isHandled()
    
  previousValue: ->
    prev = @expression[@expression_index - 1]
    if prev
      prev.value()
      
  nextValue: ->
    next = @expression[@expression_index + 1]
    if next
      next.value()

  handledPrevious: ->
    prev = @expression[@expression_index - 1]
    prev.handled()
    
  handledSurrounding: ->
    @handledPrevious()
    next = @expression[@expression_index + 1]
    next.handled()

  subExpression: ->
    new SubExpression(@expression, @expression_index + 1)
    
class SubExpression
  constructor: (@expression, @at)->
    @subexpression = @findSubexpression()

  findSubexpression: ->
    i = @at
    found = false
    rparens_to_find = 1
    subexpression_parts = []        
    while i < @expression.length
      current = @expression[i]
      if current instanceof LeftParenthesis
        rparens_to_find += 1 # we encountered another subexpression
      else if current instanceof RightParenthesis
        rparens_to_find -= 1
        if rparens_to_find == 0
          current.handled()
          found = true
          break
      else 
        subexpression_parts.push(current)
      i += 1
    if not found
      throw "There was a problem with your parentheses"
    else
      subexpression_parts

  markHandled: ->
    for exp in @subexpression
      exp.handled()
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
  toDisplay: ->
    if @hasDecimal()
      @valueAtPrecision()
    else
      if @future_as_decimal
        "#{@opts.value}."
      else
        "#{@opts.value}"

  value: -> @opts.value
  valueAtPrecision: ->
    number_decimal_places = 4
    parts = "#{@opts.value}".split(".")
    if parts[1].length > number_decimal_places
      "#{((@opts.value*1).toFixed(number_decimal_places) * 1)}"
    else
      "#{@opts.value}"

  negate: ->
    @opts.value *= -1

  concatenate: (number)->
    @opts.value = if @future_as_decimal
      @future_as_decimal = false
      "#{@opts.value}.#{number.value()}"
    else
      "#{@opts.value}#{number.value()}"

  setFutureAsDecimal: ->
    @future_as_decimal = true unless @hasDecimal()

  hasDecimal: ->
    /\./.test(@opts.value)

  invoke: (expression)->
    last = expression.last()
    if last instanceof Number
      last.concatenate(@)
    else
      expression.msg @


window.ttm.Calculator.Number = ttm.ClassMixer(Number)

class Negative extends ExpressionComponent
  toDisplay: -> "-"
  invoke: (expression)->
    last = expression.last()
    last && last.negate()

window.ttm.Calculator.Negative = ttm.ClassMixer(Negative)

class Square extends ExpressionComponent
  toDisplay: -> "<sup>2</sup>"
  invoke: (expression)->
    value = expression.evaluate().value() || 0
    num = Number.build value: "#{parseFloat(value) * parseFloat(value)}"
    expression.set([num])

window.ttm.Calculator.Square = ttm.ClassMixer(Square)

class SquareRoot extends ExpressionComponent
  toDisplay: -> "&radic;"
  invoke: (expression)->
    value = expression.evaluate().value() || 0
    num = Number.build value: "#{Math.sqrt(parseFloat(value))}"
    expression.set([num])
    
window.ttm.Calculator.SquareRoot = ttm.ClassMixer(SquareRoot)

class Exponent extends ExpressionComponent
  toDisplay: -> "^"
  eval: (evaluation, pass)->
    return @ if pass != "exponentiation"
    
    prev = evaluation.previousValue()
    next = evaluation.nextValue()
    if prev && next
      evaluation.handledSurrounding()
      Number.build(value: Math.pow(parseFloat(prev), parseFloat(next)))
    else
      throw new "Invalid Expression"
    
window.ttm.Calculator.Exponent = ttm.ClassMixer(Exponent)

class Pi extends ExpressionComponent
  toDisplay: -> "&pi;"
  eval: ->
    Number.build(value: Math.PI)

window.ttm.Calculator.Pi = ttm.ClassMixer(Pi)

class Addition extends ExpressionComponent
  toDisplay: -> "+"
  eval: (evaluation, pass)->
    return @ if pass != "addition"
    
    prev = evaluation.previousValue()
    next = evaluation.nextValue()
    if prev && next
      evaluation.handledSurrounding()
      Number.build(value: (parseFloat(prev) + parseFloat(next)))
    else
      throw new "Invalid Expression"

window.ttm.Calculator.Addition = ttm.ClassMixer(Addition)

class Subtraction extends ExpressionComponent
  toDisplay: -> "-"
  eval: (evaluation, pass)->
    return @ if pass != "addition"
    
    prev = evaluation.previousValue()
    next = evaluation.nextValue()
    if prev && next
      evaluation.handledSurrounding()
      Number.build(value: (parseFloat(prev) - parseFloat(next)))
    else
      throw  "Invalid Expression"

  
window.ttm.Calculator.Subtraction = ttm.ClassMixer(Subtraction)

class Multiplication extends ExpressionComponent
  eval: (evaluation, pass)->
    return @ if pass != "multiplication"
    prev = evaluation.previousValue()
    next = evaluation.nextValue()
    if prev && next
      evaluation.handledSurrounding()
      Number.build(value: (parseFloat(prev) * parseFloat(next)))
    else
      throw "Invalid Expression"

  toDisplay: -> "&times;"
window.ttm.Calculator.Multiplication = ttm.ClassMixer(Multiplication)

class Division extends ExpressionComponent
  toDisplay: -> "&divide;"
  eval: (evaluation, pass)->
    return @ if pass != "multiplication"
    prev = evaluation.previousValue()
    next = evaluation.nextValue()
    if prev && next
      evaluation.handledSurrounding()
      Number.build(value: (parseFloat(prev) / parseFloat(next)))
    else
      throw "Invalid Expression"

window.ttm.Calculator.Division = ttm.ClassMixer(Division)

class Decimal extends ExpressionComponent
  toDisplay: -> "."
  invoke: (expression)->
    last = expression.last()
    if last instanceof Number
      last.setFutureAsDecimal()

window.ttm.Calculator.Decimal = ttm.ClassMixer(Decimal)

class LeftParenthesis extends ExpressionComponent
  toDisplay: -> "("
  eval: (expression, pass)->
    return @ if pass != "parenthetical"
    subexpr = expression.subExpression()
    evaluated = subexpr.eval()
    subexpr.markHandled() # mark the closing parenthesis as handled
    evaluated

window.ttm.Calculator.LeftParenthesis = ttm.ClassMixer(LeftParenthesis)

class RightParenthesis extends ExpressionComponent
  toDisplay: -> ")"
  eval: -> throw "Error: parentheses mismatch"

window.ttm.Calculator.RightParenthesis = ttm.ClassMixer(RightParenthesis)

