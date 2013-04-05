describe "Calculator Widget integration", ->
  beforeEach ->
    @calc = ttm.Calculator.build_widget(f())
    @handle = JSCalculatorHandle.build(f())

  it "performs exponentiation", ->
    @handle.press_buttons("2 ^ 2 =")
    expect(@handle.output_content()).toEqual("4")
    
  it "displays what is entered", ->
    @handle.press_buttons("8")
    expect(@handle.output_content()).toEqual("8")

  it "will display decimal numbers correctly", ->
    @handle.press_buttons("1 . 0 1")
    expect(@handle.output_content()).toEqual("1.01")

  it "clears", ->
    @handle.press_buttons("8 clear")
    expect(@handle.output_content()).toEqual("0")

  it "multiplies", ->
    @handle.press_buttons("8 * 8 =")
    expect(@handle.output_content()).toEqual("64")

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

  it "supports parenthetical expressions", ->
    @handle.press_buttons("1 0 * ( 2 + 4 ) =")
    expect(@handle.output_content()).toEqual("60")

  it "divides", ->
    @handle.press_buttons("1 0 / 2 =")
    expect(@handle.output_content()).toEqual("5")
    
  it "does pi", ->
    @handle.press_buttons("pi =")
    expect(@handle.output_content()).toMatch /3.14/


describe "Calculator error handling", ->
  beforeEach ->
    @calc = ttm.Calculator.build_widget(f())
    @handle = JSCalculatorHandle.build(f())

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
    @handle.press_buttons("1 / 0 =")
    @handle.assertError()

    @handle.press_buttons("1 / 0 = 1 / 1 0 =")
    expect(@handle.output_content()).toEqual("0.1")

class JSCalculatorHandle
  initialize: ((@element)->)
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
    expect(@output_content()).toEqual(window.ttm.Calculator.LogicController.prototype.errorMsg())

window.ttm.ClassMixer(JSCalculatorHandle)


num = (it)-> ttm.Calculator.Number.build(value: it)

buttonBuilderMock = ->
  jasmine.createSpyObj('button_builder', ['buildButton']);

jqueryAppendableElementMock = ->
  jasmine.createSpyObj('jquery_element', ['append']) 

logicMock = ->
  jasmine.createSpyObj('logic_controller_mock', ['addPart', 'calculate', 'msg']);

