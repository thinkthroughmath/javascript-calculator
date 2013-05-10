#= require lib/math/expression_evaluation


describe "math expression evaluation", ->
  beforeEach ->
    @evaluation = ttm.require("lib/math/expression_evaluation")
    @math = ttm.require("lib/math")
    @exp = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression

  it "evaluates a simple addition", ->
    exp = @exp(2, '+', 7)
    results = @evaluation.build(exp).resultingExpression()
    expect(results).toEqual @exp(9)


  it "sets an error state on an invalid expression", ->
    exp = @exp('/')
    new_exp = @evaluation.build(exp).resultingExpression()
    expect(new_exp.isError()).toBeTruthy()
