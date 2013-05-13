#= require lib/math/expression_components
#= require lib/math/expression_equality


describe "expression equality", ->
  beforeEach ->
    @comps = ttm.require('lib/math/expression_components')
    @isEqual = ttm.require('lib/math/expression_equality').isEqual
    @exp_builder = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression

  describe "numbers", ->
    it "with different values are different", ->
      expect(
        @isEqual(
          @comps.number.build(value: 10),
          @comps.number.build(value: 11)
          )).toEqual false

    it "is equal with two of the same value", ->
      expect(
        @isEqual(
          @comps.number.build(value: 10),
          @comps.number.build(value: 10)
          )).toEqual true

    describe "checking against an expression", ->
      it "matches if the first element in the expression matches", ->
        expect(@comps.number.build(value: 10)).toBeAnEqualExpressionTo(
          @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ]))

  describe "expression comparison", ->
    it "accepts for empty expressions", ->
      expect(
        @isEqual(
          @comps.expression.build(),
          @comps.expression.build()
          )).toEqual true


    it "accepts expressions that have equal number internals", ->
      expect(
        @isEqual(
          @comps.expression.build(expression: [
              @comps.number.build(value: 10)
            ]),
          @comps.expression.build(expression: [
              @comps.number.build(value: 10)
            ])
          )).toEqual true

    it "rejects expressions with different numeric internals", ->
      expect(
        @isEqual(
          @comps.expression.build(expression: [
              @comps.number.build(value: 11)
            ]),
          @comps.expression.build(expression: [
              @comps.number.build(value: 10)
            ])
          )).toEqual false


    describe "comparing an expression against non-expressions", ->
      it "accepts if the first part of the sub expression is equal to what it is comparing against ", ->
        expect(
          @isEqual(
            @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ]),
            @comps.number.build(value: 10)
          )).toEqual true

      it "rejects if the first part of the sub expression is not equal", ->
        expect(
          @isEqual(
            @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ]),
            @comps.number.build(value: 11)
          )).toEqual false

  describe "addition", ->
    it "accepts two addition symbols", ->
      expect(
        @isEqual(
          @comps.addition.build(),
          @comps.addition.build()
        )).toEqual true


  describe "blank elements", ->
    it "accepts vs a blank element", ->
      expect(
        @isEqual(
          @comps.blank.build(),
          @comps.blank.build(),
        )).toEqual true

    it "rejects against numbers", ->
      expect(
        @isEqual(
          @comps.blank.build(),
          @comps.number.build(value: 1)
        )).toEqual false
    it "accepts against expressions that contain a single blank element", ->
      expect(
        @isEqual(
          @comps.blank.build(),
          @exp_builder(null)
        )).toEqual true
      expect(
        @isEqual(
          @exp_builder(null),
          @comps.blank.build()
        )).toEqual true

  describe "exponentiation", ->
    it "accepts exponents with same base and power", ->
      a = @exp_builder('^': [11, 22])
      b = @exp_builder('^': [11, 22])
      expect(a).toBeAnEqualExpressionTo b

    it "rejects exponents with differing bases", ->
      new_exp = @exp_builder('^': [11, 32])
      expected = @exp_builder('^': [12, 32])
      expect(new_exp).not.toBeAnEqualExpressionTo(expected)

    it "rejects exponents different powers",->
      new_exp = @exp_builder('^': [10, 32])
      expected = @exp_builder('^': [10, 22])
      expect(new_exp).not.toBeAnEqualExpressionTo(expected)




