#= require lib/math/expression_traversal

describe "expression traversal", ->
  beforeEach ->
    @comps = ttm.lib.math.ExpressionComponentSource.build()
    @expression_traversal = ttm.lib.math.ExpressionTraversal

  it "it returns the expression if that id matches", ->

    power_id = @comps.id_source.next()
    power_num = @comps.build_number(value: 9, id: power_id)

    power = @comps.build_expression(expression: [power_num])
    # TODO change build_expression to iterate over expression arguments
    # and add each with parent reference

    base = @comps.build_expression()
    exponentiation = @comps.build_exponentiation(power: power, base: base)

    expression = @comps.build_expression().append(exponentiation)
    power_node = @expression_traversal.build(expression).findForID(power_id)
    expect(power_node.id()).toEqual power_id
