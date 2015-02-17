ttm = thinkthroughmath
calculator = ttm.widgets.Calculator

# TODO move most of these to the evaluation class
describe "Calculator Widget features", ->
  beforeEach ->
    math = ttm.lib.math.math_lib.build()
    @calc = calculator.build_widget(f())
    @handle = JSCalculatorHandle.build(f(), calculator)

  it "displays what is entered", ->
    @handle.press_buttons("8")
    expect(@handle.output_content()).toEqual("8")

  it "displays html entities", ->
    @handle.press_buttons("8 * 8")
    expect(@handle.output_content()).not.toMatch /\*/

  it "performs exponentiation", ->
    @handle.press_buttons("2 ^ 2 =")
    expect(@handle.output_content()).toEqual("4")

  it "example for debugging", ->
     @handle.press_buttons("2 ^ 5 + 1 ) 4")
     expect(@handle.output_content()).toEqual(parseEntities "2 &circ; ( 5 + 1 ) &times; 4")

  it "supports button ordering and specification via initialization options", ->
    f().html("")
    @calc = calculator.build_widget(f(), ['0', 'clear'])
    @handle = JSCalculatorHandle.build(f(), calculator)
    expect(@handle.button('0').siblings().length).toEqual 2

  describe "multiple sequential operator button presses", ->
    it "automatically uses the last entered operator", ->
      @handle.press_buttons("2 + - * / ^ 1 0 =")
      expect(@handle.output_content()).toEqual("1024")

  it "will display decimal numbers correctly", ->
    @handle.press_buttons("1 . 0 1")
    expect(@handle.output_content()).toEqual("1.01")

  describe "clearing", ->
    it "works", ->
      @handle.press_buttons("8 clear")
      expect(@handle.output_content()).toEqual("0")

    describe "clearing after a calculation", ->
      it "automatically clears when another number starts getting entered after a calculation", ->
        @handle.press_buttons("2 + 2 = 1 2 3")
        expect(@handle.output_content()).toEqual("123")

      it "preserves numbers for future calculations", ->
        @handle.press_buttons("2 + 2 = + 1 3 5 =")
        expect(@handle.output_content()).toEqual("139")

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

  it "crashes on roots followed by another operation", ->
    @handle.press_buttons("9 root + 1 =")
    expect(@handle.output_content()).toEqual("4")

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

    it "correctly handles side by side parentheticals", ->
      @handle.press_buttons("8 ( 9 ) ( 8 ) =")
      expect(@handle.output_content()).toEqual("576")


    it "correctly handles side by side parentheticals", ->
      @handle.press_buttons("8 ( ( 9 + 5 ) 2 ) =")
      expect(@handle.output_content()).toEqual("224")


    # not working currently,
    xit "displays partial parentheses", ->
      @handle.press_buttons("8 (")
      expect(@handle.output_content()).toEqual(parseEntities "8 &times; (")


  it "divides", ->
    @handle.press_buttons("1 0 / 2 =")
    expect(@handle.output_content()).toEqual("5")

  describe "pi", ->
    it "does pi", ->
      @handle.press_buttons("pi =")
      expect(@handle.output_content()).toMatch /3.14/

    it "multiplies pis side by side", ->
      @handle.press_buttons("pi pi =")
      expect(@handle.output_content()).toMatch /9.86/

    it "handles a more complicated example", ->
      @handle.press_buttons("2 pi ( 1 + 3 ) =")
      expect(@handle.output_content()).toMatch /25.13/

    it "handles another compilcated example", ->
      @handle.press_buttons("pi 2 pi ( 1 + 3 ) ( 1 0 ) =")
      expect(@handle.output_content()).toMatch /789.5684/

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
    math = ttm.lib.math.math_lib.build()
    @calc = calculator.build_widget(f(), math.expression)
    @handle = JSCalculatorHandle.build(f(), calculator)

  describe "malformed expressions", ->
    it "handles division", ->
      @handle.press_buttons("/ =")
      @handle.assertError()

  describe "invalid expressions", ->
    it "handles square roots", ->
      @handle.press_buttons("1 negative root")
      @handle.assertError()
    it "handles division by zero", ->

  it "continues after an error has occurred", ->
    @handle.press_buttons("1 negative root 1 / 1 0 =")
    expect(@handle.output_content()).toEqual("0.1")


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
    @element.find("figure.jc--display")

  output_content: ->
    @output().text()

  assertError: ->
    expect(@output_content()).toEqual(@calculator_constructor.prototype.errorMsg())

ttm.class_mixer(JSCalculatorHandle)


num = (it)-> math.build_number(it)

buttonBuilderMock = ->
  jasmine.createSpyObj('button_builder', ['buildButton']);

jqueryAppendableElementMock = ->
  jasmine.createSpyObj('jquery_element', ['append'])

logicMock = ->
  jasmine.createSpyObj('logic_controller_mock', ['addPart', 'calculate', 'msg']);

