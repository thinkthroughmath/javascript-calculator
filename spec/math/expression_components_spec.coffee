ttm = thinkthroughmath

it_adheres_to_the_expression_component_interface = (opts)->
  describe "expression component interface", ->
    beforeEach ->
      @comp = opts.instance_fn.call(@)
    it "responds to ID", ->
      expect(@comp.id()).toEqual opts.id

    describe "after cloning it", ->
      it "maintains its id", ->
        new_comp = @comp.clone()
        expect(new_comp.id()).toEqual opts.id

    it "has type-introspection methods", ->
      # just want to verify that these are methods
      # would fail if they weren't
      @comp.isExpression()
      @comp.isFraction()
      @comp.isNumber()
      @comp.isVariable()
      @comp.isFraction()
      @comp.isExponentiation()
      @comp.isRoot()

describe "Expression Components", ->
  beforeEach ->
    @comps = ttm.lib.math.ExpressionComponentSource.build()

    @expression_to_string = (exp)->
      ttm.lib.math.ExpressionToString.toString(exp)

    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value
    @math = ttm.lib.math.math_lib.build()
    @h = new Helper(@comps)

  describe "expressions", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_expression(id: 9876)
      id: 9876
    }

    it "assigns components from its construtor", ->
      exp = @comps.build_expression(
        expression: [
          @comps.build_number(value: '10')
        ])
      exp_pos = @math.expression_position.buildExpressionPositionAsLast(exp)
      @expect_value(exp_pos, '10')

    it "is isExpression", ->
      expect(@comps.build_expression().isExpression()).toEqual true

  describe "numbers", ->
    beforeEach ->
      @n = (arg)=> @math.components.build_number(arg)
    it "returns a number with a negative version", ->
      num = @comps.classes.number.build(value: 10)
      neg_num = num.negated()
      expect(neg_num.value()).toEqual "-10"

    it "supports concatenation", ->
      expect(@n(value: 1).concatenate(0).concatenate(1).value()).toEqual '101'

    it "supports concatenation with a decimal", ->
      expect(@n(value: 1).futureAsDecimal().concatenate(0).concatenate(1).value()).toEqual '1.01'

    it "normalizes fractions in its constructor", ->
      expect(@n(value: "1/4").value()).toEqual '0.25'

  describe "roots", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_root(
          degree: @h.numberExpression(2),
          radicand: @h.numberExpression(100),
          id: 12345)

      id: 12345
    }

    beforeEach ->
      @root = @comps.build_root(
        degree: @h.numberExpression(2),
        radicand: @h.numberExpression(100)
      )

    it "has a reference to the degree", ->
      expect(@root.degree()).toBeAnEqualExpressionTo @h.numberExpression(2)

    it "has a reference to the radicand", ->
      expect(@root.radicand()).toBeAnEqualExpressionTo @h.numberExpression(100)

    it "can update its radicand", ->
      new_rad = @h.numberExpression(5)
      updated = @root.updateRadicand(new_rad)

      expect(updated.degree()).toBeAnEqualExpressionTo @h.numberExpression(2)
      expect(updated.radicand()).toBeAnEqualExpressionTo @h.numberExpression(5)

    it "clones correctly", ->
      new_root = @root.clone()
      new_root.doot = 10

      expect(@root).toBeAnEqualExpressionTo(new_root)
      expect(@root.doot).not.toBeAnEqualExpressionTo new_root.doot

  describe "division", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_division(id: 12345)
      id: 12345
    }

  describe "variables", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_variable(name: "example", id: 678)
      id: 678
    }

    it "will tell you its name", ->
      @variable = @comps.build_variable(name: "doot")
      expect(@variable.name()).toEqual("doot")

  describe "fns", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_fn(name: "example", id: 678)
      id: 678
    }

  describe "fraction", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_fraction(id: 678)
      id: 678
    }

    it "is isFraction", ->
      @frac = @comps.build_fraction()
      expect(@frac.isFraction()).toEqual true

  describe "pi", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_pi(id: 678)
      id: 678
    }

    it "defaults to the js value", ->
      expect(@comps.build_pi().value()).toMatch /3.14159/

    it "allows overridden values", ->
      expect(@comps.build_pi(value: 3).value()).toEqual 3

class Helper
  constructor: (@comps)->
  number: (num)->
    @comps.build_number(value: num)
  expression: (cont)->
    @comps.build_expression expression: cont
  numberExpression: (num)->
    @expression(@number(num))
