#= require lib/math/expression_position

describe "expression position library", ->
  beforeEach ->
    @builder = ttm.require('lib/math/build_expression_from_javascript_object').build().
      builderFunction()
    @ep_builder = ttm.lib.math.ExpressionPosition

  it "holds a reference to the expression", ->
    ep = @ep_builder.build(expression: 'face')
    expect(ep.expression()).toEqual 'face'

  it "holds the id of the node that is currently being pointed to", ->
    ep = @ep_builder.build(position: 10)
    expect(ep.position()).toEqual 10


  describe "building with pointer at end of expression", ->
    it "sets the pointer", ->
      basic = @builder()
      output = @ep_builder.builderFunctionForExpressionPositionAsLast(basic)
      expect(output.expression()).toBeAnEqualExpressionTo(basic)
      expect(output.position()).toEqual(basic.id())
