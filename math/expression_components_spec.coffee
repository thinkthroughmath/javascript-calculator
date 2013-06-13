
it_adheres_to_the_expression_component_interface = (opts)->
  describe "expression component interface", ->
    beforeEach ->
      @comp = opts.instance_fn.call(@)

    it "returns the correct repsonse for isOperator", ->
      expect(@comp.isOperator()).toEqual opts.is_operator

    it "responds to ID", ->
      expect(@comp.id()).toEqual opts.id

describe "Expression Components", ->
  beforeEach ->
    @comps = ttm.lib.math.ExpressionComponentSource.build()
    @expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value

  describe "Expression", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.build_expression(id: 9876)
      is_operator: false
      id: 9876
    }

    it "assigns components from its construtor", ->
      exp = @comps.build_expression(
        expression: [
          @comps.build_number(value: '10')
        ])
      @expect_value(exp, '10')

    describe "'openness'/'incompleteness'", ->
      beforeEach ->
        @exp = @comps.build_expression()

      it "responds to isOpen with 'false' by default", ->
        expect(@exp.isOpen()).toEqual false

      it "has an opening method which returns an open expression", ->
        open_exp = @exp.open()
        expect(open_exp.isOpen()).toEqual true
        expect(open_exp).toBeInstanceOf @comps.classes.expression

      it "has a closing method which returns a closed expression", ->
        exp = @exp.open().close()
        expect(exp.isOpen()).toEqual false
        expect(exp).toBeInstanceOf @comps.classes.expression

  describe "numbers", ->
    beforeEach ->
      @n = @comps.classes.number.build
    it "returns a number with a negative version", ->
      num = @comps.classes.number.build(value: 10)
      neg_num = num.negated()
      expect(neg_num.value()).toEqual -10

    it "supports concatenation", ->
      expect(@n(value: 1).concatenate(0).concatenate(1).value()).toEqual '101'

    it "supports concatenation with a decimal", ->
      expect(@n(value: 1).futureAsDecimal().concatenate(0).concatenate(1).value()).toEqual '1.01'

  describe "roots", ->
    beforeEach ->
      @root = @comps.classes.root.build(degree: 2, radicand: 100)

    it "has a reference to the degree", ->
      expect(@root.degree()).toEqual 2

    it "has a reference to the radicand", ->
      expect(@root.radicand()).toEqual 100

    it "can update its radicand", ->
      updated = @root.updateRadicand(5)
      expect(updated.degree()).toEqual 2
      expect(updated.radicand()).toEqual 5


  describe "division", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.classes.division.build(id: 12345)
      is_operator: true
      id: 12345
    }

  describe "variables", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.classes.variable.build(name: "example", id: 678)
      is_operator: false
      id: 678
    }

    it "will tell you its name", ->
      @variable = @comps.classes.variable.build(name: "doot")
      expect(@variable.name()).toEqual("doot")
