#= require lib/math
#= require lib/math/build_expression_from_javascript_object

describe "BuildExpressionFromJavascriptObject", ->
  beforeEach ->
    @builder = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression
    @components = ttm.require('lib/math/expression_components')

  it "builds an empty expression", ->
    expect(@builder() instanceof @components.expression).toBeTruthy()

  it "handles numbers", ->
    expression = @builder(10)
    expect(expression.first().value()).toEqual 10

  it "handles addition", ->
    expression = @builder(10, '+', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.addition
    expect(expression.last().value()).toEqual 11

  it "handles division", ->
    expression = @builder(10, '/', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.division
    expect(expression.last().value()).toEqual 11

  it "handles multiplication", ->
    expression = @builder(10, '*', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.multiplication
    expect(expression.last().value()).toEqual 11


  describe 'exponentiation', ->
    it 'handles a standard case', ->
      expression = @builder '^': [10, 11]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.exponentiation

      base = exponentiation.base()
      expect(base).toBeInstanceOf @components.number
      expect(base.value()).toEqual 10

      power = exponentiation.power()
      expect(power).toBeInstanceOf @components.number
      expect(power.value()).toEqual 11

    it 'supports incomplete exponentiations (as blank member)', ->
      expression = @builder '^': [10, null]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.exponentiation
      expect(exponentiation.power()).toBeInstanceOf @components.blank

  it "handles parenthetical sub-expressions via arrays", ->
    expression = @builder []
    sub_exp = expression.first()
    expect(expression).toBeInstanceOf @components.expression
    expect(sub_exp).toBeInstanceOf @components.expression

  it "uses object syntax with label 'open_expression' to signify an open expression", ->
    expression = @builder open_expression: [10]
    sub_exp = expression.first()
    expect(sub_exp.isOpen()).toEqual(true)
