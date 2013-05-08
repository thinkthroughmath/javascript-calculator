#= require lib/math
#= require lib/math/build_expression_from_javascript_object

describe "BuildExpressionFromJavascriptObject", ->
  beforeEach ->
    @builder = ttm.require('lib/math/build_expression_from_javascript_object')
    @components = ttm.require('lib/math/expression_components')

  it "builds an empty expression", ->
    expect(@builder() instanceof @components.expression).toBeTruthy()

  it "handles numbers", ->
    expression = @builder(10)
    expect(expression.first().value()).toEqual '10'

  it "handles addition", ->
    expression = @builder(10, '+', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.addition
    expect(expression.last().value()).toEqual '11'

  it "handles division", ->
    expression = @builder(10, '/', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.division
    expect(expression.last().value()).toEqual '11'


  it 'handles exponentiation', ->
    expression = @builder '^': [10, 11]
    exponentiation = expression.nth(0)
    expect(exponentiation).toBeInstanceOf @components.exponentiation

    base = exponentiation.base()
    expect(base).toBeInstanceOf @components.number
    expect(base.value()).toEqual '10'

    power = exponentiation.power()
    expect(power).toBeInstanceOf @components.number
    expect(power.value()).toEqual '11'

