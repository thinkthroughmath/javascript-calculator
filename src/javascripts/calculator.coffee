ttm = thinkthroughmath
class_mixer = ttm.class_mixer
expression_to_string = ttm.lib.math.ExpressionToString
historic_value = ttm.lib.historic_value

ui_elements = ttm.widgets.UIElements.build()
math_buttons_lib = ttm.widgets.ButtonBuilder
components = ttm.lib.math.ExpressionComponentSource.build()

calculator_wrapper_class = 'jc'

class Calculator
  @build_widget: (element, buttonsToRender=null)->
    math = ttm.lib.math.math_lib.build()
    Calculator.build(element, math, ttm.logger, buttonsToRender)

  initialize: (@element, @math, @logger, @buttonsToRender)->
    @view = CalculatorView.build(@, @element, @math, @buttonsToRender)
    @expression_position = historic_value.build()
    @updateCurrentExpressionWithCommand @math.commands.build_reset()
    @typeLastPressed = ""

  displayValue: ->
    exp_pos = @expression_position.current()
    exp = exp_pos.expression()
    exp_contains_cursor = @math.traversal.build(exp_pos).buildExpressionComponentContainsCursor()
    if !exp.isError()
      val = expression_to_string.toHTMLString(exp_pos, exp_contains_cursor)
      if val.length == 0
        '0'
      else
        val
    else
      @errorMsg()

  display: ->
    to_disp = @displayValue()
    @view.display(to_disp)

  errorMsg: -> "Error"

  updateCurrentExpressionWithCommand: (command)->
    new_exp = command.perform(@expression_position.current())
    @reset_on_next_number = false
    @expression_position.update(new_exp)
    @display()
    @expression_position.current()

  # specification actions
  numberClick: (button_options)->
    @typeLastPressed = "number"
    if @reset_on_next_number
      @reset_on_next_number = false
      @updateCurrentExpressionWithCommand @math.commands.build_reset()

    cmd = @math.commands.build_append_number(value: button_options.value)
    @updateCurrentExpressionWithCommand cmd

  exponentClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "exponent"
    @updateCurrentExpressionWithCommand @math.commands.build_exponentiate_last()

  negativeClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "negative"
    @updateCurrentExpressionWithCommand @math.commands.build_negate_last()

  additionClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "addition"
    @updateCurrentExpressionWithCommand @math.commands.build_append_addition()

  multiplicationClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "multiplication"
    @updateCurrentExpressionWithCommand @math.commands.build_append_multiplication()

  divisionClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "division"
    @updateCurrentExpressionWithCommand @math.commands.build_append_division()

  subtractionClick: ->
    if @typeLastPressed == "exponent" || @typeLastPressed == "lparen"
      return
    @typeLastPressed = "subtraction"
    @updateCurrentExpressionWithCommand @math.commands.build_append_subtraction()

  decimalClick: ->
    @typeLastPressed = "decimal"
    if @reset_on_next_number
      @reset_on_next_number = false
      @updateCurrentExpressionWithCommand @math.commands.build_reset()

    @updateCurrentExpressionWithCommand @math.commands.build_append_decimal()

  # command actions
  clearClick: ->
    @typeLastPressed = "clear"
    @updateCurrentExpressionWithCommand @math.commands.build_reset()

  equalsClick: ->
    @typeLastPressed = "equals"
    @updateCurrentExpressionWithCommand @math.commands.build_calculate()
    @reset_on_next_number = true

  squareClick: ->
    @typeLastPressed = "square"
    @updateCurrentExpressionWithCommand @math.commands.build_square()
    @reset_on_next_number = true

  squareRootClick: ->
    @typeLastPressed = "squareRoot"
    @updateCurrentExpressionWithCommand @math.commands.build_square_root()
    @reset_on_next_number = true

  lparenClick: ->
    @typeLastPressed = "lparen"
    @updateCurrentExpressionWithCommand @math.commands.build_append_sub_expression()

  rparenClick: ->
    @typeLastPressed = "rparen"
    @updateCurrentExpressionWithCommand @math.commands.build_exit_sub_expression()

  piClick: ->
    @typeLastPressed = "pi"
    @updateCurrentExpressionWithCommand @math.commands.build_append_pi()

class_mixer(Calculator)

class ButtonLayout
  initialize: ((@components, @buttonsToRender=false)->)
  render: (@element)->
    defaultButtons = [
        "square", "square_root", "exponent", "clear",
        "pi", "lparen", "rparen", "division",
        '7', '8', '9', "multiplication",
        '4', '5', '6', "subtraction",
        '1', '2', '3', "addition",
        '0', "decimal", "negative", "equals"
      ]
    @renderComponents(@buttonsToRender || defaultButtons)

  render_component: (comp)->
    @components[comp].render element: @element

  renderComponents: (components)->
    for comp in components
      @render_component comp

class_mixer(ButtonLayout)

class CalculatorView
  initialize: (@calc, @element, @math, @buttonsToRender)->

    math_button_builder = math_buttons_lib.build
      element: @element
      ui_elements: ui_elements

    # for button layout
    buttons = {}

    numbers = math_button_builder.base10Digits click: (val)=>@calc.numberClick(val)
    for num in [0..9]
      buttons["#{num}"] = numbers[num]

    buttons.negative = math_button_builder.negative click: => @calc.negativeClick()
    buttons.decimal = math_button_builder.decimal click: => @calc.decimalClick()
    buttons.addition = math_button_builder.addition click: => @calc.additionClick()
    buttons.multiplication = math_button_builder.multiplication click: => @calc.multiplicationClick()
    buttons.division = math_button_builder.division click: => @calc.divisionClick()
    buttons.subtraction = math_button_builder.subtraction click: => @calc.subtractionClick()
    buttons.equals = math_button_builder.equals click: => @calc.equalsClick()

    buttons.clear = math_button_builder.clear click: => @calc.clearClick()
    buttons.square = math_button_builder.exponent value: "square", power: "2", click: => @calc.squareClick()
    buttons.square_root = math_button_builder.root click: => @calc.squareRootClick()
    buttons.exponent = math_button_builder.caret click: => @calc.exponentClick()

    buttons.lparen = math_button_builder.lparen click: => @calc.lparenClick()
    buttons.rparen = math_button_builder.rparen click: => @calc.rparenClick()
    buttons.pi = math_button_builder.pi click: => @calc.piClick()

    @layout = ButtonLayout.build(buttons, @buttonsToRender)

    @render()

  display: (content)->
    disp = @element.find("figure.jc--display")
    disp.html(content)
    disp.scrollLeft(9999999)
    display_text = content.replace(/-/g, "minus").replace(/\(/g, "left paranthesis").replace(/\)/g, "right paranthesis").replace(/&circ;/g, "to the power of")
    $('#statusMessageContent').html(display_text)

  render: ->
    @element.append "<div class='#{calculator_wrapper_class}'></div>"
    calc_div = @element.find("div.#{calculator_wrapper_class}")
    calc_div.append "<figure class='jc--display'>0</figure>"

    @layout.render calc_div

class_mixer(CalculatorView)

ttm.widgets.Calculator = Calculator
