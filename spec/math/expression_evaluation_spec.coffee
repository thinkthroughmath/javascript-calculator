#= require lib/math/expression_evaluation

expect_evaluation = (orig, goal)->
  exp = @exp(orig)
  new_exp = @evaluation.build(exp).resultingExpression()
  expect(new_exp).toBeAnEqualExpressionTo @exp(goal)




describe "math expression evaluation", ->
  beforeEach ->
    @evaluation = ttm.require("lib/math/expression_evaluation")
    @math = ttm.lib.math.math_lib.build()
    builder_lib = ttm.require('lib/math/build_expression_from_javascript_object')
    @exp = @math.object_to_expression.buildExpressionFunction()
    @expect_evaluation = expect_evaluation

  it "evaluates a simple addition", ->
    exp = @exp(2, '+', 7)
    results = @evaluation.build(exp).resultingExpression()
    expect(results).toBeAnEqualExpressionTo @exp(9)

  it "sets an error state on an invalid expression", ->
    exp = @exp('/')
    new_exp = @evaluation.build(exp).resultingExpression()

    expect(new_exp.isError()).toBeTruthy()

  it "evaluates a simple exponentiation",->
    exp = @exp('^': [2, 10])
    new_exp = @evaluation.build(exp).resultingExpression()
    expect(new_exp).toBeAnEqualExpressionTo @exp(1024)

  it "evaluates this sample expression correctly", ->
    exp = @exp(10, '*', [2, '+', 4])
    new_exp = @evaluation.build(exp).resultingExpression()
    expect(new_exp).toBeAnEqualExpressionTo @exp(60)

  it "evaluates division", ->
    @expect_evaluation(
      ['20', '/', '2.5'],
      '8'
    )

  it "evaluates fractional division", ->
    @expect_evaluation(
      {fraction: ['20', '2.5']}
      '8'
    )

  it "evaluates this expression correctly", ->
    @expect_evaluation(
      [
        [
          "41", '/', "32.75", '-', '1'
        ], '*', '100'
      ],
      '25.19'
    )


