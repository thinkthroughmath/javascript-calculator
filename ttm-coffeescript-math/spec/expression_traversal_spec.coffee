ttm = thinkthroughmath

describe "expression traversal", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @comps = @math.components
    @expression_traversal = @math.traversal

    @exp_pos_builder = @math.object_to_expression.buildExpressionPositionFunction()

  it "it returns the expression if that id matches", ->

    power_id = @comps.id_source.next()
    power_num = @comps.build_number(value: 9, id: power_id)

    power = @comps.build_expression(expression: [power_num])

    base = @comps.build_expression()
    exponentiation = @comps.build_exponentiation(power: power, base: base)

    expression = @comps.build_expression().append(exponentiation)

    expression_position = @math.expression_position.buildExpressionPositionAsLast(expression)

    power_node = @expression_traversal.build(expression_position).findForID(power_id)
    expect(power_node.id()).toEqual power_id

  describe "expression component contains cursor process", ->
    it "works", ->
      exp_pos = @exp_pos_builder({fraction: []}, cursor([]))
      contains_decider = @expression_traversal.build(exp_pos)

      contains_decider = contains_decider.buildExpressionComponentContainsCursor()
      wrapping_exp = exp_pos.expression()
      expect(contains_decider.isCursorWithinComponent(wrapping_exp)).toEqual true

