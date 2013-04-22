#= require almond_wrapper
#= require lib
#= require lib/math
#= require lib/math/buttons
#= require widgets/ui_elements

ttm.define "calculator",
  ["lib/class_mixer", "lib/math", "widgets/ui_elements", "lib/math/buttons"],
  (class_mixer, math, ui_elements, math_buttons)->

    open_widget_dialog = (element)->
      if element.empty()
        Calculator.build_widget(element)
      element.dialog(dialogClass: "calculator-dialog", title: "Calculator")
      element.dialog("open")

    class Calculator
      @build_widget: (element)->
        Calculator.build(element, math)

      initialize: (@element, @math)->
        @view = CalculatorView.build(@, @element, @math)
        @current_expression = @math.expression.build()
        @expression_history = []

      displayValue: ->
        if !@current_expression.isError()
          val = @current_expression.display()
          if val.length == 0
            '0'
          else
            val
        else
          @errorMsg()

      display: ->
        @view.display(@displayValue())

      errorMsg: -> "Error"

      updateCurrentExpression: (new_exp)->
        @reset_on_next_number = false
        @expression_history.push @current_expression
        @current_expression = new_exp
        @display()
        @current_expression

      updateCurrentExpressionWithCommand: (command)->
        @updateCurrentExpression(command.invoke(@current_expression))

      # specification actions
      numberClick: (button_options)->
        if @reset_on_next_number
          @reset_on_next_number = false
          @updateCurrentExpression @math.expression.build()

        cmd = @math.commands.number.build(value: button_options.value)
        @updateCurrentExpressionWithCommand cmd

      exponentClick: ->
        @updateCurrentExpressionWithCommand @math.commands.exponentiation.build()

      negativeClick: ->
        @updateCurrentExpressionWithCommand @math.commands.negation.build()

      additionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.addition.build()

      multiplicationClick: ->
        @updateCurrentExpressionWithCommand @math.commands.multiplication.build()

      divisionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.division.build()

      subtractionClick: ->
        @updateCurrentExpressionWithCommand @math.commands.subtraction.build()

      decimalClick: ->
        @updateCurrentExpressionWithCommand @math.commands.decimal.build()

      # command actions
      clearClick: ->
        @updateCurrentExpression @math.expression.build()

      equalsClick: ->
        @updateCurrentExpressionWithCommand @math.commands.calculate.build()
        @reset_on_next_number = true

      squareClick: ->
        @updateCurrentExpressionWithCommand @math.commands.square.build()
        @reset_on_next_number = true

      squareRootClick: ->
        @updateCurrentExpressionWithCommand @math.commands.square_root.build()
        @reset_on_next_number = true

      lparenClick: ->
        @updateCurrentExpressionWithCommand @math.commands.left_parenthesis.build()

      rparenClick: ->
        @updateCurrentExpressionWithCommand @math.commands.right_parenthesis.build()

      piClick: ->
        @updateCurrentExpressionWithCommand @math.commands.pi.build()

      buttonFor: (opts)->
        opts = _.extend({
          button_builder: @button_builder
          logic: @logic
          element: @element
        }, opts)

        @button_builder.build opts

    class_mixer(Calculator)

    class LogicController
      initialize: (@expression)->
        @current_expression = @expression.build()

      onResultChange: ((@handler)->)

      calculate: ->
        @resetIfError()
        @current_expression.calculate()
        @display()

      resetIfError: ->
        @current_expression.isError() && @current_expression.reset()

      numberClick: ->
      msg: (part)->
        @resetIfError()
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

    class_mixer(LogicController)



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
