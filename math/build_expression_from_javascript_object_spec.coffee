#= require lib/math
describe "BuildExpressionFromJavascriptObject", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @components = @math.components
    builder_lib = ttm.require('lib/math/build_expression_from_javascript_object')

    @exp_pos_builder = @math.object_to_expression.buildExpressionPositionFunction()
    @builder = @math.object_to_expression.buildExpressionFunction()

  it "builds an empty expression", ->
    expect(@builder() instanceof @components.classes.expression).toBeTruthy()

  it "handles numbers", ->
    expression = @builder(10)
    expect(expression.first().value()).toEqual "10"

  it "handles numbers that have trailing decimals", ->
    expression = @builder("0.")
    x = expression.first()
    expect(x.value()).toEqual "0"

    expect(x.future_as_decimal).toEqual true

  it "handles addition", ->
    expression = @builder(10, '+', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.classes.number
    expect(expression.nth(1)).toBeInstanceOf @components.classes.addition
    expect(expression.last().value()).toEqual "11"

  it "handles division", ->
    expression = @builder(10, '/', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.classes.number
    expect(expression.nth(1)).toBeInstanceOf @components.classes.division
    expect(expression.last().value()).toEqual "11"

  it "handles multiplication", ->
    expression = @builder(10, '*', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.classes.number
    expect(expression.nth(1)).toBeInstanceOf @components.classes.multiplication
    expect(expression.last().value()).toEqual "11"

  it "handles roots", ->
    expression = @builder(root: [2, 4])
    expect(expression.first()).toBeInstanceOf @components.classes.root

  it "handles pi", ->
    expression = @builder(10, 'pi', 11)
    expect(expression.nth(0)).toBeInstanceOf @components.classes.number
    expect(expression.nth(1)).toBeInstanceOf @components.classes.pi
    expect(expression.last().value()).toEqual "11"

  it "handles variables", ->
    expression = @builder({variable: "doot"})
    expect(expression.nth(0)).toBeInstanceOf @components.classes.variable
    expect(expression.nth(0).name()).toEqual "doot"

  describe 'exponentiation', ->
    it 'creates exponentiation objects from caret object notation', ->
      expression = @builder '^': [10, 11]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.classes.exponentiation

      base = exponentiation.base()
      expect(base).toBeInstanceOf @components.classes.expression
      expect(base.first().value()).toEqual "10"

      power = exponentiation.power()
      expect(power).toBeInstanceOf @components.classes.expression
      expect(power.first().value()).toEqual "11"

    it 'supports incomplete exponentiations (as an empty expression)', ->
      expression = @builder '^': [10, null]
      exponentiation = expression.nth(0)
      expect(exponentiation).toBeInstanceOf @components.classes.exponentiation
      expect(exponentiation.power()).toBeInstanceOf @components.classes.expression

  it "handles parenthetical sub-expressions via arrays", ->
    expression = @builder []
    sub_exp = expression.first()
    expect(expression).toBeInstanceOf @components.classes.expression
    expect(sub_exp).toBeInstanceOf @components.classes.expression


  describe "handles fraction", ->
    it "handles base case", ->
      expression = @builder({fraction: [1, 2]})
      sub_exp = expression.first()
      expect(expression).toBeInstanceOf @components.classes.expression
      expect(sub_exp).toBeInstanceOf @components.classes.fraction

  describe "handling function syntax", ->
    it "converts to a Fn object", ->
      expression = @builder(fn: ["doot", 2])
      sub_exp = expression.first()
      expect(sub_exp).toBeInstanceOf @components.classes.fn

  describe "building expression position", ->
    describe "with nothing marked", ->
      it "sets the last item in the expression list as the current expression", ->
        results = @exp_pos_builder(10)
        expect(results.expression()).toBeAnEqualExpressionTo @builder(10)
        expect(results.position()).toEqual results.expression().id()

    describe "with an element marked", ->
      describe "setting the marked item in the expression list as the current expression works for", ->
        it "fractions", ->
          results = @exp_pos_builder({fraction:[null, cursor([])]})
          expect(results.expression()).toBeAnEqualExpressionTo @builder(fraction: [])
          expect(results.position()).toEqual results.expression().last().denominator().id()

        it "exponents", ->
          results = @exp_pos_builder({'^':[null, cursor([])]})
          expect(results.expression()).toBeAnEqualExpressionTo @builder('^': [])
          expect(results.position()).toEqual results.expression().last().power().id()

        it "subexpressions", ->
          results = @exp_pos_builder([cursor([])])
          expect(results.expression()).toBeAnEqualExpressionTo @builder([[]])
          expect(results.position()).toEqual results.expression().first().first().id()

