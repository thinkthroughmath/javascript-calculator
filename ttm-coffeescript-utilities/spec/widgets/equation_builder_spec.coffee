ttm = thinkthroughmath
equation_builder = ttm.widgets.EquationBuilder

equation_buidler_data = '{"variables":[{"variableName":"time","isUnknown":"false","variableValue":"1.5","unitName":"hours"},{"variableName":"distance","isUnknown":"false","variableValue":"12","unitName":"miles"},{"variableName":"speed","isUnknown":"true","variableValue":"8","unitName":"mph"}]}'

describe "equation builder widget", ->
  beforeEach ->
    @variables = [ { name: "time" }, { name: "distance" }, { name: "speed" } ]
    @eb = equation_builder.build(
      element: f()
      variables: @variables
      mathml_renderer: {renderMathMLInElement: ->})

    @h = new EquationBuilderHandle(f(), @eb)

  describe "integration", ->
    it "displays an entered number", ->
      @h.press_buttons("1 2 3 4")
      results = @h.mathmlJquery()
      expect(results.find("mn").text()).toEqual "1234"

    it "displays entered numbers plus equations", ->
      @h.press_buttons("1 2 3 4 + 4 5 6 6")

      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "1234"
      expect(results.find("mo").first().text()).toEqual "+"
      expect(results.find("mn").eq(1).text()).toEqual "4566"

    it "displays entered numbers times numbers", ->
      @h.press_buttons("1 2 3 4 * 4 5 6 6")
      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "1234"
      expect(results.find("mo").first().text()).toEqual parsedDomText("&times;")
      expect(results.find("mn").eq(1).text()).toEqual "4566"


    it "displays entered numbers divided by other numbers", ->
      @h.press_buttons("1 2 3 4 / 4 5 6 6")
      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "1234"
      expect(results.find("mo").first().text()).toEqual parsedDomText("&divide;")
      expect(results.find("mn").eq(1).text()).toEqual "4566"

    it "displays entered numbers subtraction by other numbers", ->
      @h.press_buttons("1 2 3 4 - 4 5 6 6")

      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "1234"
      expect(results.find("mo").first().text()).toEqual "-"
      expect(results.find("mn").eq(1).text()).toEqual "4566"

    it "allows decimals", ->
      @h.press_buttons("1 . 2 - 3 . 7")

      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "1.2"
      expect(results.find("mo").first().text()).toEqual "-"
      expect(results.find("mn").eq(1).text()).toEqual "3.7"

    it "will clear an expression", ->
      @h.press_buttons("1 clear 2")

      results = @h.mathmlJquery()
      expect(results.find("mn").first().text()).toEqual "2"

    it "has a pi button", ->
      @h.press_buttons("pi")
      results = @h.mathmlJquery()
      expect(results.find("mi:first").text()).toEqual parsedDomText("&pi;")

    it "allows inserting of square roots", ->
      @h.press_buttons("1 root 1 0 )")

      results = @h.mathmlJquery()
      expect(results.find("msqrt").length).toBeTruthy

    it "allows inserting variables", ->
      @h.press_buttons("time")
      results = @h.mathmlJquery()
      expect(results.find("mi").first().text()).toEqual "time"

    it "inserts numerator/denomimnators", ->
      @h.press_buttons("fraction")
      results = @h.mathmlJquery()
      expect(results.find("mfrac").length).not.toEqual(0)


    # we arent using these for now! disbaleeedd
    xit "inserts cos", ->
      @h.press_buttons("function[cos]")
      results = @h.mathmlJquery()
      expect(results.find("mi:contains('cos')").length).not.toEqual(0)

    it "allows for a user to delete the previous element", ->
      @h.press_buttons("1 2 + 3 4 del")
      results = @h.mathmlJquery()
      expect(results.find("mn").last().text()).toEqual "12"
      expect(results.find("mo").text()).toEqual "+"
      expect(results.find("mo:last").text()).toEqual "+"

    it "allows the user to negate elements", ->
      @h.press_buttons("1 2 -/+")
      results = @h.mathmlJquery()
      expect(results.find("mn").last().text()).toEqual "-12"


  describe "the ui structure", ->
    beforeEach ->
      @h = new EquationBuilderHandle(f())

    describe "rendering buttons", ->
      beforeEach ->
        @buttons = @h.buttons()

      describe "control buttons", ->
        it "equals", ->
          @buttons.expectIncludes("=")

        it "division", ->
          @buttons.expectIncludes("/")

        it "multiplication", ->
          @buttons.expectIncludes("*")

        it "subtraction", ->
          @buttons.expectIncludes("-")

        it "addition", ->
          @buttons.expectIncludes("+")

        it "negative", ->
          @buttons.expectIncludes "-/+"

        it "clear", ->
          @buttons.expectIncludes "clear"

        it "delete", ->
          @buttons.expectIncludes "del"

        it "square", ->
          @buttons.expectIncludes "square"

        it "cube", ->
          @buttons.expectIncludes "cube"

        it "exponent", ->
          @buttons.expectIncludes "exponentiate"

        it "square root", ->
          @buttons.expectIncludes "square-root"

        it "cubed root", ->
          @buttons.expectIncludes "cubed-root"

        it "cubed root", ->
          @buttons.expectIncludes "root"

        it "lparen", ->
          @buttons.expectIncludes "("

        it "rparen", ->
          @buttons.expectIncludes ")"

        it "pi", ->
          @buttons.expectIncludes "pi"

        it "fraction", ->
          @buttons.expectIncludes "fraction"



      # we arent using these for now! disbaleeedd
      xdescribe "advanced buttons", ->
        it "sin", ->
          @buttons.expectIncludes "function[sin]"

        it "cos", ->
          @buttons.expectIncludes "function[cos]"

        it "tan", ->
          @buttons.expectIncludes "function[tan]"

        it "arcsin", ->
          @buttons.expectIncludes "function[arcsin]"

        it "arccos", ->
          @buttons.expectIncludes "function[arccos]"

        it "arctan", ->
          @buttons.expectIncludes "function[arctan]"

      describe "number buttons", ->
        it "0..9", ->
          _.each [0...9], (num)=>
            @buttons.expectIncludes("#{num}")

        it "decimal", ->
          @buttons.expectIncludes(".")


    describe "the element that the displays the equation", ->
      it "exists", ->
        expect(@h.equationDisplay()).toExist()

      it "has the correct class", ->
        expect(@h.equationDisplay()).toHaveClass "mathml-display"


    describe "variable selection", ->
      it "provides variables", ->
        selectable_variables = @h.selectableVariables()

        expect(selectable_variables).toContain "time"
        expect(selectable_variables).toContain "distance"
        expect(selectable_variables).toContain "speed"

  describe "external interactions", ->
    it "has a method that will allow for clearing", ->
      @h.press_buttons("1 2 3 4")

      expect(@eb.expression_position_value.current().expression().size()).toEqual 1
      @eb.clear()
      expect(@eb.expression_position_value.current().expression().size()).toEqual 0

    it "gives a callback that will be provided data", ->
      math_ml = false
      @eb.onMathMLChange (m)->
        math_ml = m
      @h.press_buttons("1 2 3 4")
      expect($(math_ml).find("mn").text()).toEqual("1234")

class EquationBuilderHandle
  constructor: (@element, @eb)->

  buttons: ->
    new EquationBuilderButtons(@element.find("button"))

  equationDisplay: ->
    @element.find("figure.equation-display")

  button: (which)->
    @element.find("button[value='#{which}']")

  press_button: (which)->
    btn = @button(which)
    if btn.length == 0
      throw "Could not press button '#{which}' as it does not exist"
    else
      btn.click()

  press_buttons: (buttons)->
    for button in buttons.split(" ")
      do (button)=>
        @press_button(button) unless button.length == 0

  output: ->
    @element.find("figure.mathml-display")

  output_content: ->
    @output().text()

  assertError: ->
    expect(@output_content()).toEqual(@calculator_constructor.prototype.errorMsg())

  selectableVariables: ->
    vars = []
    @element.find('button.variable').map (i, variable)->
      vars.push($(variable).text())
    vars

  mathmlJquery: ->
    $(@eb.mathML())

class EquationBuilderButtons
  constructor: (@buttons)->

  includes: (looking_for)->
    found = false
    @buttons.each (i, btn)->
      found = btn if $(btn).val() == looking_for
    found

  expectIncludes: (looking_for)->
    expect(@includes(looking_for)).toBeTruthy()

