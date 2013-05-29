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

  it "handles numbers that have trailing decimals", ->
    expression = @builder("0.")
    x = expression.first()
    expect(x.value()).toEqual "0"

    expect(x.future_as_decimal).toEqual true

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

  it "handles roots", ->
    expression = @builder(root: [2, 4])
    expect(expression.first()).toBeInstanceOf @components.root

  it "handles pi", ->
    expression = @builder(10, 'pi', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.number
    expect(expression.nth(1)).toBeInstanceOf @components.pi
    expect(expression.last().value()).toEqual 11

  describe 'exponentiation', ->
    it 'handles a standard case', ->
      expression = @builder '^': [10, 11]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.exponentiation

      base = exponentiation.base()
      expect(base).toBeInstanceOf @components.expression
      expect(base.first().value()).toEqual 10

      power = exponentiation.power()
      expect(power).toBeInstanceOf @components.expression
      expect(power.first().value()).toEqual 11

    it 'supports incomplete exponentiations (as an empty expression)', ->
      expression = @builder '^': [10, null]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.exponentiation
      expect(exponentiation.power()).toBeInstanceOf @components.expression


  it "handles parenthetical sub-expressions via arrays", ->
    expression = @builder []
    sub_exp = expression.first()
    expect(expression).toBeInstanceOf @components.expression
    expect(sub_exp).toBeInstanceOf @components.expression

  describe "open expressions", ->
    it "uses object syntax with label 'open_expression' to signify an open expression", ->
      expression = @builder open_expression: [10]
      sub_exp = expression.first()
      expect(sub_exp.isOpen()).toEqual(true)


    it "building an open expression with some elements in it", ->
      exp = @builder open_expression: [10, '*',  10]

      expect(exp).toBeInstanceOf @components.expression
      expect(exp.isOpen()).toEqual false # it is wrapped with a closed expression

      open = exp.first()

      expect(open).toBeInstanceOf @components.expression
      expect(open.isOpen()).toEqual true


      ten = open.first()
      expect(ten).toBeInstanceOf @components.number
      expect(ten.value()).toEqual 10

    it "building a closed expression inside an open expression", ->
      exp = @builder(open_expression: [[]])

      open = exp.first()
      expect(open).toBeInstanceOf @components.expression
      expect(open.isOpen()).toEqual true

      closed = open.first()
      expect(closed).toBeInstanceOf @components.expression
      expect(closed.isOpen()).toEqual false
      expect(closed.size()).toEqual 0

    it "building nested open expressions", ->
      expression = @builder {open_expression: {open_expression: 10}}

      first_open = expression.first()
      expect(first_open.isOpen()).toEqual(true)

      second_open = first_open.first()
      expect(second_open.isOpen()).toEqual(true)

      ten = second_open.first()
      expect(ten.value()).toEqual 10


