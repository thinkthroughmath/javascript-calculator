#= require lib/math/expression_to_string

describe "expression to string conversion", ->
  it "converts a simple addition expression", ->
    to_string = ttm.require("lib/math/expression_to_string").toString
    builder = ttm.require("lib/math/build_expression_from_javascript_object").buildExpression
    expect(to_string(builder(1, '+', 2))).toEqual "1 + 2"

  it "converts an exponentiation to a string", ->
    to_string = ttm.require("lib/math/expression_to_string").toString
    builder = ttm.require("lib/math/build_expression_from_javascript_object").buildExpression
    expect(to_string(builder('^': [1, 2]))).toEqual "1^2"

