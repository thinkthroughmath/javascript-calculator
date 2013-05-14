describe "Expression Components", ->
  beforeEach ->
    @comps = ttm.require('lib/math/expression_components')
    @expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value

  describe "Equation", ->
    it "responds to last", ->
      eq = @comps.equation.build()
      expect(eq.last()).toEqual null

    it "responds to append", ->
      eq = @comps.equation.build()
      x = eq.append(@comps.number.build(value: 10))
      expect(x.last().value()).toEqual 10

    it "responds to replaceLast", ->
      tt = @comps.number.build(value: '22')
      eq = @comps.equation.build(@comps.expression.buildWithContent [tt])
      x = eq.replaceLast(@comps.number.build(value: '10'))
      expect(x.last().value()).toEqual '10'

  describe "Expression", ->
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
