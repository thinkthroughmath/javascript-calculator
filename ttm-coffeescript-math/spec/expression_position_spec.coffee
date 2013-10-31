ttm = thinkthroughmath

describe "expression position library", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @builder = @math.object_to_expression.buildExpressionFunction()
    @ep_builder = @math.expression_position

  it "holds a reference to the expression", ->
    ep = @ep_builder.build(expression: 'face')
    expect(ep.expression()).toEqual 'face'

  it "holds the id of the node that is currently being pointed to", ->
    ep = @ep_builder.build(position: 10)
    expect(ep.position()).toEqual 10
