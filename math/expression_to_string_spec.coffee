#= require lib/math/expression_to_string

describe "expression to string conversion", ->
  beforeEach ->
    @to_string = ttm.require("lib/math/expression_to_string").toString
    @builder = ttm.require("lib/math/build_expression_from_javascript_object").buildExpression
  it "converts a simple addition expression", ->
    expect(@to_string(@builder(1, '+', 2))).toEqual "1 + 2"

  it "converts an exponentiation to a string", ->
    expect(@to_string(@builder('^': [1, 2]))).toEqual "1^2"

  it "correctly displays a complicated decimal number", ->
    expect(@to_string(@builder(Math.PI))).toEqual "3.1416"
