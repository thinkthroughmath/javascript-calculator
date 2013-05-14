#= require lib/math/expression_to_string

describe "expression to string conversion", ->
  beforeEach ->
    @to_string = ttm.require("lib/math/expression_to_string").toString
    @to_html_string = ttm.require("lib/math/expression_to_string").toHTMLString
    @builder = ttm.require("lib/math/build_expression_from_javascript_object").buildExpression
  it "converts a simple addition expression", ->
    expect(@to_string(@builder(1, '+', 2))).toEqual "1 + 2"


  it "correctly displays a complicated decimal number", ->
    expect(@to_string(@builder(Math.PI))).toEqual "3.1416"

  describe "exponentiation", ->
    it "converts to a string", ->
      exp = @builder('^': [1, 2])
      expect(@to_string(exp)).toEqual "1 ^ 2"
      expect(@to_html_string(exp)).toEqual "1 &circ; 2"

    it "displays incomplete exponentiations correctly", ->
      exp = @builder('^': [10, null])
      expect(@to_string(exp)).toEqual "10 ^ "
      expect(@to_html_string(exp)).toEqual "10 &circ; "

  describe "multiplication", ->
    it "", ->
      exp = @builder(10, '*',  10)
      expect(@to_string(exp)).toEqual "10 * 10"
      expect(@to_html_string(exp)).toEqual "10 &times; 10"


  describe "sub-expressions", ->
    it "displays them as parentheses", ->
      exp = @builder([10, '*',  10])
      expect(@to_string(exp)).toEqual "( 10 * 10 )"
      expect(@to_html_string(exp)).toEqual "( 10 &times; 10 )"

    it "displays open sub-expressions with a single parenthesis", ->
      exp = @builder({open_expression: [10, '*',  10]})
      expect(@to_string(exp)).toEqual "( 10 * 10"
