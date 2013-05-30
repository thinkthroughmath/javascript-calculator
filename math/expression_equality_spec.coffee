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

    it "rejects expressions that are of different lengths", ->
      expect(
        @isEqual(
          @comps.expression.build(expression: []),
          @comps.expression.build(expression: [
              @comps.number.build(value: 10)
            ])
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

  describe "multiplication", ->
    it "accepts two multiplication symbols", ->
      expect(
        @isEqual(
          @comps.multiplication.build(),
          @comps.multiplication.build()
        )).toEqual true

  describe "division", ->
    it "accepts two division symbols", ->
      expect(
        @isEqual(
          @comps.division.build(),
          @comps.division.build()
        )).toEqual true

  describe "pi", ->
    it "accepts two pi symbols", ->
      expect(
        @isEqual(
          @comps.pi.build(),
          @comps.pi.build()
        )).toEqual true

  describe "equals", ->
    it "accepts two equals symbols", ->
      expect(
        @isEqual(
          @comps.subtraction.build(),
          @comps.subtraction.build()
        )).toEqual true

  describe "subtraction", ->
    it "accepts two subtraction symbols", ->
      expect(
        @isEqual(
          @comps.equals.build(),
          @comps.equals.build()
        )).toEqual true

  describe "root", ->
    it "accepts roots with equal degrees and radicands", ->
      a = @exp_builder(root: [10, 20])
      b = @exp_builder(root: [10, 20])
      expect(a).toBeAnEqualExpressionTo b

    it "rejects roots with different degrees", ->
      a = @exp_builder(root: [10, 20])
      b = @exp_builder(root: [1, 20])
      expect(a).not.toBeAnEqualExpressionTo b

    it "rejects roots with different radicands", ->
      a = @exp_builder(root: [10, 20])
      b = @exp_builder(root: [10, 4])
      expect(a).not.toBeAnEqualExpressionTo b

  describe "variable", ->
    it "accepts with equal variable names", ->
      a = @exp_builder(variable: "doot")
      b = @exp_builder(variable: "doot")
      expect(a).toBeAnEqualExpressionTo b

    it "rejects with different variable names", ->
      a = @exp_builder(variable: "doot")
      b = @exp_builder(variable: "scoot")
      expect(a).not.toBeAnEqualExpressionTo b
