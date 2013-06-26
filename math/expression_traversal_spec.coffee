#= require lib/math/expression_traversal

describe "expression traversal", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @comps = @math.components
    @expression_traversal = @math.traversal

  it "it returns the expression if that id matches", ->

    power_id = @comps.id_source.next()
    power_num = @comps.build_number(value: 9, id: power_id)

    power = @comps.build_expression(expression: [power_num])

    base = @comps.build_expression()
    exponentiation = @comps.build_exponentiation(power: power, base: base)

    expression = @comps.build_expression().append(exponentiation)
    power_node = @expression_traversal.build(expression).findForID(power_id)
    expect(power_node.id()).toEqual power_id
