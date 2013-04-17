#= require widgets/calculator
#= require lib/math
#= require almond



describe "Calculator Widget integration", ->
  beforeEach ->
    calculator = require("calculator")
    math = require("lib/math")
    @calc = calculator.build_widget(f(), math.expression)
    @handle = require("calc_handle").build(f(), calculator)

  it "displays what is entered", ->
    @handle.press_buttons("8")
    expect(@handle.output_content()).toEqual("8")

  describe "multiple sequential operator button presses", ->
    it "automatically clears when another number starts getting entered after a calculation", ->
      @handle.press_buttons("2 + - * / ^ 1 0 =")
      expect(@handle.output_content()).toEqual("1024")

  describe "clearing after calculation", ->
    it "automatically clears when another number starts getting entered after a calculation", ->
      @handle.press_buttons("2 ^ 2 = 1 2 3")
      expect(@handle.output_content()).toEqual("123")

    it "preserves numbers for future calculations", ->
      @handle.press_buttons("2 ^ 2 = + 1 3 5 =")
      expect(@handle.output_content()).toEqual("139")

  it "will display decimal numbers correctly", ->
    @handle.press_buttons("1 . 0 1")
    expect(@handle.output_content()).toEqual("1.01")

  it "performs exponentiation", ->
    @handle.press_buttons("2 ^ 2 =")
    expect(@handle.output_content()).toEqual("4")

  it "clears", ->
    @handle.press_buttons("8 clear")
    expect(@handle.output_content()).toEqual("0")

  describe "multiplication", ->
    it "handles a typical case", ->
      @handle.press_buttons("8 * 8 =")
      expect(@handle.output_content()).toEqual("64")

    it "handles the edge case", ->
      @handle.press_buttons("0 * 1 =")
      expect(@handle.output_content()).toEqual("0")

  it "adds", ->
    @handle.press_buttons("1 2 3 + 1 2 3 =")
    expect(@handle.output_content()).toEqual("246")

  it "subtracts", ->
    @handle.press_buttons("1 2 3 - 1 2 0 =")
    expect(@handle.output_content()).toEqual("3")

  it "allows decimals", ->
    @handle.press_buttons("1 . 2")
    expect(@handle.output_content()).toEqual("1.2")

  it "performs decimal calculations", ->
    @handle.press_buttons("1 . 0 1 * 1 1 =")
    expect(@handle.output_content()).toEqual("11.11")

  it "negates numbers", ->
    @handle.press_buttons("1 1 negative")
    expect(@handle.output_content()).toEqual("-11")

  it "squares", ->
    @handle.press_buttons("1 0 square =")
    expect(@handle.output_content()).toEqual("100")

  it "will negate a nuber that is already entered" , ->
    @handle.press_buttons("1 1 negative")
    expect(@handle.output_content()).toEqual("-11")

  describe "parentheses", ->
    it "supports parenthetical expressions", ->
      @handle.press_buttons("1 0 * ( 2 + 4 ) =")
      expect(@handle.output_content()).toEqual("60")

    it "supports implicit multiplication", ->
      @handle.press_buttons("1 0 ( 2 ) =")
      expect(@handle.output_content()).toEqual("20")

    it "supports implicit multiplication reversed", ->
      @handle.press_buttons("( 2 ) 1 0 0 =")
      expect(@handle.output_content()).toEqual("200")

  it "divides", ->
    @handle.press_buttons("1 0 / 2 =")
    expect(@handle.output_content()).toEqual("5")


  describe "pi", ->
    it "does pi", ->
      @handle.press_buttons("pi =")
      expect(@handle.output_content()).toMatch /3.14/

    it "multiplies pi", ->
      @handle.press_buttons("5 pi =")
      expect(@handle.output_content()).toMatch /15.708/
    it "multiplies pi reversed", ->
      @handle.press_buttons("pi 5 =")
      expect(@handle.output_content()).toMatch /15.708/

  it "handles order of operations correctly", ->
    @handle.press_buttons("1 + 1 - 2 * 2 =")
    expect(@handle.output_content()).toMatch /-2/

  describe "decimal entry", ->
    it "displays 0 at first", ->
      expect(@handle.output_content()).toMatch /0/

    it "displays 0. when user presses a period", ->
      @handle.press_buttons(".")
      expect(@handle.output_content()).toEqual "0."

    it "displays 0.1 when user continues to add numbers", ->
      @handle.press_buttons(". 1")
      expect(@handle.output_content()).toEqual "0.1"

    it "handles pressing decimal after an operator", ->
      @handle.press_buttons(". 1 + . 1")

      expect(@handle.output_content()).toEqual "0.1 + 0.1"

describe "Calculator error handling", ->
  beforeEach ->
    calculator = require("calculator")
    math = require("lib/math")
    @calc = calculator.build_widget(f(), math.expression)
    @handle = require("calc_handle").build(f(), calculator)

  describe "malformed expressions", ->
    it "handles division", ->
      @handle.press_buttons("/ =")
      @handle.assertError()

  describe "invalid expressions", ->
    it "handles square roots", ->
      @handle.press_buttons("1 negative squareroot")
      @handle.assertError()
    it "handles division by zero", ->

  it "continues after an error has occurred", ->
    @handle.press_buttons("1 negative squareroot 1 / 1 0 =")
    expect(@handle.output_content()).toEqual("0.1")





define "calc_handle", ['lib/class_mixer'], (class_mixer)->
  class JSCalculatorHandle
    initialize: ((@element, @calculator_constructor)->)
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
          @press_button(button)

    output: ->
      @element.find("figure.calculator-display")

    output_content: ->
      @output().text()

    assertError: ->
      expect(@output_content()).toEqual(@calculator_constructor.prototype.errorMsg())

  class_mixer(JSCalculatorHandle)

  return JSCalculatorHandle


num = (it)-> math.build_number(it)

buttonBuilderMock = ->
  jasmine.createSpyObj('button_builder', ['buildButton']);

jqueryAppendableElementMock = ->
  jasmine.createSpyObj('jquery_element', ['append'])

logicMock = ->
  jasmine.createSpyObj('logic_controller_mock', ['addPart', 'calculate', 'msg']);

