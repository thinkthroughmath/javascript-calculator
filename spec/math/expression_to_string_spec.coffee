#= require lib/math/expression_to_string

describe "expression to string conversion", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    trav =
    @to_string = (exp)->
      exp_contains_cursor = @math.traversal.build(exp).buildExpressionComponentContainsCursor()
      ttm.require("lib/math/expression_to_string").toString(exp, exp_contains_cursor)

    @to_html_string = (exp)->
      exp_contains_cursor = @math.traversal.build(exp).buildExpressionComponentContainsCursor()
      ttm.require("lib/math/expression_to_string").toHTMLString(exp, exp_contains_cursor)

    @exp_pos_builder = @math.object_to_expression.buildExpressionFunction()
    @exp_pos_builder = @math.object_to_expression.buildExpressionPositionFunction()

  it "converts a simple addition expression", ->
    expect(@to_string(@exp_pos_builder(1, '+', 2))).toEqual "1 + 2"

  it "correctly displays a complicated decimal number", ->
    expect(@to_string(@exp_pos_builder(Math.PI))).toEqual "3.1416"

  describe "exponentiation", ->
    it "converts to a string", ->
      exp = @exp_pos_builder('^': [1, 2])
      expect(@to_string(exp)).toEqual "1 ^ ( 2 )"
      expect(@to_html_string(exp)).toEqual "1 &circ; ( 2 )"

    it "displays incomplete exponentiations correctly", ->
      power = []

      exp = @exp_pos_builder('^': [10, []])
      expect(@to_string(exp)).toEqual "10 ^ ( "
      expect(@to_html_string(exp)).toEqual "10 &circ; ( "

  describe "multiplication", ->
    it "", ->
      exp = @exp_pos_builder(10, '*',  10)
      expect(@to_string(exp)).toEqual "10 * 10"
      expect(@to_html_string(exp)).toEqual "10 &times; 10"

  describe "sub-expressions", ->
    it "displays them as parentheses", ->
      exp = @exp_pos_builder([10, '*',  10])
      expect(@to_string(exp)).toEqual "( 10 * 10 )"
      expect(@to_html_string(exp)).toEqual "( 10 &times; 10 )"

    it "displays sub-expressions that contain the cursor with a single parenthesis", ->
      exp = @exp_pos_builder(cursor([10, '*',  10]))
      expect(@to_string(exp)).toEqual "( 10 * 10"

    it "displays partial parentheses", ->
      exp = @exp_pos_builder(10, '*', [])
      actual = @to_html_string(exp)
      expect(actual).toEqual "10 &times; ( "

    it "displays single sub-expressions with parentheses", ->
      exp = @exp_pos_builder(10, '*', [5])
      actual = @to_html_string(exp)
      expect(actual).toEqual "10 &times; ( 5 )"

  it "correctly displays pi", ->
    exp = @exp_pos_builder('pi')
    actual = @to_html_string(exp)
    expect(actual).toEqual "<span class='expression-to-string-pi'>&pi;</span>"
