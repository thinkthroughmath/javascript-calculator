
it_adheres_to_the_expression_component_interface = (opts)->
  describe "expression component interface", ->
    beforeEach ->
      @comp = opts.instance_fn.call(@)

    it "returns the correct repsonse for isOperator", ->
      expect(@comp.isOperator()).toEqual opts.is_operator


describe "Expression Components", ->
  beforeEach ->
    @comps = ttm.require('lib/math/expression_components')
    @expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value

  describe "Expression", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.expression.build()
      is_operator: false
    }

    it "assigns components from its construtor", ->
      exp = @comps.expression.build(
        expression: [
          @comps.number.build(value: '10')
        ])
      @expect_value(exp, '10')

    describe "'openness'/'incompleteness'", ->
      beforeEach ->
        @exp = @comps.expression.build()

      it "responds to isOpen with 'false' by default", ->
        expect(@exp.isOpen()).toEqual false

      it "has an opening method which returns an open expression", ->
        open_exp = @exp.open()
        expect(open_exp.isOpen()).toEqual true
        expect(open_exp).toBeInstanceOf @comps.expression

      it "has a closing method which returns a closed expression", ->
        exp = @exp.open().close()
        expect(exp.isOpen()).toEqual false
        expect(exp).toBeInstanceOf @comps.expression

  describe "numbers", ->
    beforeEach ->
      @n = @comps.number.build
    it "returns a number with a negative version", ->
      num = @comps.number.build(value: 10)
      neg_num = num.negated()
      expect(neg_num.value()).toEqual -10

    it "supports concatenation", ->
      expect(@n(value: 1).concatenate(0).concatenate(1).value()).toEqual '101'

    it "supports concatenation with a decimal", ->
      expect(@n(value: 1).futureAsDecimal().concatenate(0).concatenate(1).value()).toEqual '1.01'

  describe "roots", ->
    beforeEach ->
      @root = @comps.root.build(degree: 2, radicand: 100)

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
        @comps.division.build()
      is_operator: true
      }

  describe "variables", ->
    it_adheres_to_the_expression_component_interface {
      instance_fn: ->
        @comps.variable.build(name: "example")
      is_operator: false
      }

    it "will tell you its name", ->
      @variable = @comps.variable.build(name: "doot")
      expect(@variable.name()).toEqual("doot")
