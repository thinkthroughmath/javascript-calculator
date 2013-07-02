#= require almond_wrapper
#= require lib
#= require lib/math
#= require widgets/math_buttons
#= require widgets/ui_elements
#= require lib/math/expression_to_string
#= require lib/math/expression_components

ttm.define "calculator",
  ["lib/class_mixer", "widgets/ui_elements", "lib/math/buttons", 'lib/math/expression_to_string', 'lib/historic_value'],
  (class_mixer,  ui_elements, math_buttons,
    expression_to_string, historic_value)->
    components = ttm.lib.math.ExpressionComponentSource.build()

    open_widget_dialog = (element)->
      if element.empty()
        Calculator.build_widget(element)
      element.dialog(dialogClass: "calculator-dialog", title: "Calculator")
      element.dialog("open")
      element.dialog({ position: { my: 'right center', at: 'right center', of: window}})

    class Calculator
      @build_widget: (element)->
        math = ttm.lib.math.math_lib.build()
        Calculator.build(element, math, logger)

      initialize: (@element, @math, @logger)->
        @view = CalculatorView.build(@, @element, @math)
        @expression_position = historic_value.build()
        @updateCurrentExpressionWithCommand @math.commands.build_reset()

      displayValue: ->
        exp = @expression_position.current().expression()
        if !exp.isError()
          val = expression_to_string.toHTMLString(exp)
          if val.length == 0
            '0'
          else
            val
        else
          logger.warn("display value is error")
          @errorMsg()

      display: ->
        to_disp = @displayValue()
        logger.info("calculator display #{to_disp}")
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
        if @reset_on_next_number
          @reset_on_next_number = false
          @updateCurrentExpressionWithCommand @math.commands.build_reset()

        cmd = @math.commands.build_append_number(value: button_options.value)
        @updateCurrentExpressionWithCommand cmd

      exponentClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_exponentiate_last()

      negativeClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_negate_last()

      additionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_addition()

      multiplicationClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_multiplication()

      divisionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_division()

      subtractionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_subtraction()

      decimalClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_decimal()

      # command actions
      clearClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_reset()

      equalsClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_calculate()
        @reset_on_next_number = true

      squareClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_square()
        @reset_on_next_number = true

      squareRootClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_square_root()
        @reset_on_next_number = true

      lparenClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_open_sub_expression()

      rparenClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_close_sub_expression()

      piClick: ->
        @updateCurrentExpressionWithCommand @math.commands.build_append_pi()

      buttonFor: (opts)->
        opts = _.extend({
          button_builder: @button_builder
          logic: @logic
          element: @element
        }, opts)

        @button_builder.build opts

    class_mixer(Calculator)

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
          @components.numbers[num].render(element: @element)

      render_component: (comp)->
        @components[comp].render element: @element

      render_components: (components)->
        for comp in components
          @render_component comp

    class_mixer(ButtonLayout)


    class CalculatorView
      initialize: (@calc, @element, @math)->

        @button_builder = ui_elements.button_builder
        math_button_builder = math_buttons.makeBuilder
          element: @element

        # for button layout
        buttons = {}
        buttons.numbers = math_button_builder.base10Digits click: (val)=>@calc.numberClick(val)
        buttons.negative = math_button_builder.negative click: => @calc.negativeClick()
        buttons.decimal = math_button_builder.decimal click: => @calc.decimalClick()
        buttons.addition = math_button_builder.addition click: => @calc.additionClick()
        buttons.multiplication = math_button_builder.multiplication click: => @calc.multiplicationClick()
        buttons.division = math_button_builder.division click: => @calc.divisionClick()
        buttons.subtraction = math_button_builder.subtraction click: => @calc.subtractionClick()
        buttons.equals = math_button_builder.equals click: => @calc.equalsClick()

        buttons.clear = math_button_builder.clear click: => @calc.clearClick()
        buttons.square = math_button_builder.square click: => @calc.squareClick()
        buttons.square_root = math_button_builder.square_root click: => @calc.squareRootClick()
        buttons.exponent = math_button_builder.exponent click: => @calc.exponentClick()

        buttons.lparen = math_button_builder.lparen click: => @calc.lparenClick()
        buttons.rparen = math_button_builder.rparen click: => @calc.rparenClick()
        buttons.pi = math_button_builder.pi click: => @calc.piClick()

        @layout = ButtonLayout.build buttons

        @render()

      display: (content)->
        disp = @element.find("figure.calculator-display")
        disp.html(content)
        disp.scrollLeft(9999999)

      render: ->
        @element.append "<div class='calculator'></div>"
        calc_div = @element.find('div.calculator')
        calc_div.append "<figure class='calculator-display'>0</figure>"

        @layout.render calc_div

    class_mixer(CalculatorView)


    Calculator.openWidgetDialog = open_widget_dialog
    return Calculator
