#= require lib/math/expression_components
#= require lib/math/expression_equality


describe "expression equality", ->
  beforeEach ->
    @comps = ttm.lib.math.ExpressionComponentSource.build()
    @isEqual = ttm.require('lib/math/expression_equality').isEqual
    builder_lib = ttm.require('lib/math/build_expression_from_javascript_object')

    @math = ttm.lib.math.math_lib.build()
    @exp_builder = @math.object_to_expression.builderFunction()

  describe "numbers", ->
    it "with different values are different", ->
      expect(
        @isEqual(
          @comps.build_number(value: 10),
          @comps.build_number(value: 11)
          )).toEqual false

    it "is equal with two of the same value", ->
      expect(
        @isEqual(
          @comps.build_number(value: 10),
          @comps.build_number(value: 10)
          )).toEqual true

  describe "expression comparison", ->
    it "accepts for empty expressions", ->
      expect(
        @isEqual(
          @comps.build_expression(),
          @comps.build_expression()
          )).toEqual true

    it "accepts expressions that have equal number internals", ->
      expect(
        @isEqual(
          @comps.build_expression(expression: [
              @comps.build_number(value: 10)
            ]),
          @comps.build_expression(expression: [
              @comps.build_number(value: 10)
            ])
          )).toEqual true

    it "rejects expressions with different numeric internals", ->
      expect(
        @isEqual(
          @comps.build_expression(expression: [
              @comps.build_number(value: 11)
            ]),
          @comps.build_expression(expression: [
              @comps.build_number(value: 10)
            ])
          )).toEqual false

    it "rejects expressions that are of different lengths", ->
      expect(
        @isEqual(
          @comps.build_expression(expression: []),
          @comps.build_expression(expression: [
              @comps.build_number(value: 10)
            ])
          )).toEqual false

  describe "addition", ->
    it "accepts two addition symbols", ->
      expect(
        @isEqual(
          @comps.build_addition(),
          @comps.build_addition()
        )).toEqual true


  describe "blank elements", ->
    it "accepts vs a blank element", ->
      expect(
        @isEqual(
          @comps.build_blank(),
          @comps.build_blank(),
        )).toEqual true

    it "rejects against numbers", ->
      expect(
        @isEqual(
          @comps.build_blank(),
          @comps.build_number(value: 1)
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
          @comps.build_multiplication(),
          @comps.build_multiplication()
        )).toEqual true

  describe "division", ->
    it "accepts two division symbols", ->
      expect(
        @isEqual(
          @comps.build_division(),
          @comps.build_division()
        )).toEqual true

  describe "pi", ->
    it "accepts two pi symbols", ->
      expect(
        @isEqual(
          @comps.build_pi(),
          @comps.build_pi()
        )).toEqual true

  describe "equals", ->
    it "accepts two equals symbols", ->
      expect(
        @isEqual(
          @comps.build_subtraction(),
          @comps.build_subtraction()
        )).toEqual true

  describe "subtraction", ->
    it "accepts two subtraction symbols", ->
      expect(
        @isEqual(
          @comps.build_equals(),
          @comps.build_equals()
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
