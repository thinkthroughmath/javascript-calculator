#= require lib/math/expression_manipulation


it_plays_command_role = (subject, math)->
  describe "acting as an expression command", ->
    beforeEach ->
      @subject = subject(@)

    it "has an invoke method", ->
      expect(typeof @subject.invoke).toEqual "function"

    it "returns an expression", ->
      ret = @subject.invoke(@math.expression.build())
      unless ret instanceof @math.expression
        throw "The return value was not an instance of the expression builder"

describe "expression manipulations", ->
  beforeEach ->
    @math = ttm.require('lib/math')
    @components = ttm.require('lib/math/expression_components')
    @manip = ttm.require('lib/math/expression_manipulation')
    @exp_builder = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression
    @expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value

  describe "exponentiate last element", ->
    describe "on a single number-only expression", ->
      beforeEach ->
        @exp = @exp_builder(10)
        @new_exp = @manip.exponentiate_last.build().invoke(@exp)

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder(10).first()

    describe "on an expression that currently has an addition at the end", ->
      it "'drops' the addition", ->
        exp = @exp_builder(10, '+')
        new_exp = @manip.exponentiate_last.build().invoke(exp)
        expect(new_exp).toBeAnEqualExpressionTo @exp_builder('^': [10, null])

    describe "on an expression that has a trailing exponent", ->
      it "ignores the previous exponentiation", ->
        exp = @exp_builder('^': [10, null])
        new_exp = @manip.exponentiate_last.build().invoke(exp)
        expect(new_exp).toBeAnEqualExpressionTo @exp_builder('^': [10, null])

  describe "add number to end of expression", ->
    describe "when the last element in the expression is a parenthesis", ->
      beforeEach ->
        @exp = @exp_builder([1])

      it "adds a multiplication symbol between elements", ->
        exp = @manip.add_number_to_end.build(value: 11).invoke(@exp)
        other = @exp_builder([1], '*', 11)
        expect(exp).toBeAnEqualExpressionTo other


    describe "when the command to be manipulated has an exponentiation ", ->
      describe "with no power", ->
        beforeEach ->
          @exp = @exp_builder('^': [10, null])

        it "inserts the number into the exponentiation", ->
          new_exp = @manip.add_number_to_end.build(value: 11).invoke(@exp)
          expected = @exp_builder({'^': [10,11]})
          expect(new_exp).toBeAnEqualExpressionTo expected

  describe "opening a new sub expression", ->
    it "adds a sub-expression to the expression", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.open_sub_expression.build().invoke(@exp)
      expected = @exp_builder(1, '+', [])
      expect(new_exp).toBeAnEqualExpressionTo expected

    it "adds an expression that isOpen", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.open_sub_expression.build().invoke(@exp)

      exp = new_exp.nth(2)
      expect(exp).toBeInstanceOf @math.components.expression
      expect(exp.isOpen()).toEqual true

  describe "closing a sub expression WIP", ->
    it "takes an open subexpression and closes it", ->
      exp = @exp_builder({open_expression: []})
      new_exp = @manip.close_sub_expression.build().invoke(exp)
      expect(new_exp).toBeAnEqualExpressionTo @exp_builder([])

    it "correctly handles nested open subexpressions", ->
      exp = @exp_builder({open_expression: [{open_expression: []}]})
      new_exp = @manip.close_sub_expression.build().invoke(exp)
      expected = @exp_builder([[1]])
      expect(new_exp).toBeAnEqualExpressionTo expected
      #throw "should not accept"

  describe "(moved over from other test file)", ->
    describe "the square command", ->
      beforeEach ->
        @square = @manip.square.build()

      it_plays_command_role (test)->
        test.square

      it "returns a squared expression", ->
        exp = @exp_builder(10)
        squared = @square.invoke(exp)
        @expect_value(squared, '100')

    describe "the decimal command", ->
      it "correctly adds a decimal to the value", ->
        exp = @math.expression.build()
        exp = @manip.add_number_to_end.build(value: 1).invoke(exp)
        exp = @manip.decimal.build().invoke(exp)
        exp = @manip.add_number_to_end.build(value: 1).invoke(exp)
        @expect_value(exp, '1.1')

    describe "NumberCommand", ->
      it_plays_command_role (test)->
        test.manip.add_number_to_end.build(value: 5)

    describe "DecimalCommand", ->
      it_plays_command_role (test)->
        test.manip.decimal.build(value: 5)

    describe "MultiplicationCommand", ->
      it_plays_command_role (test)->
        test.manip.multiplication.build()

      it "adds multiplication to the end of the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @manip.multiplication.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.multiplication).toEqual true


    describe "SubtractionCommand", ->
      it_plays_command_role (test)->
        test.manip.subtraction.build()

      it "adds subtraction to the end of the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])

        new_exp = @manip.subtraction.build().invoke(exp)

        expect(new_exp.last() instanceof @math.components.subtraction).toEqual true

    describe "NegationCommand", ->
      it_plays_command_role (test)->
        test.manip.negate_last.build()

      it "will negate the last element", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @manip.negate_last.build().invoke(exp)
        expect(new_exp.last().value()).toEqual -1

    describe "LeftParenthesisCommand", ->
      beforeEach ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        @new_exp = @manip.left_parenthesis.build().invoke(exp)

      it_plays_command_role (test)->
        test.manip.left_parenthesis.build()

      it "adds a parenthesis to the expression", ->
        expect(@new_exp.last() instanceof @math.components.left_parenthesis).toBeTruthy()

      it "adds a multiplication to the expression when the previous item is a number", ->
        expect(@new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    describe "RightParenthesisCommand", ->
      it_plays_command_role (test)->
        test.manip.right_parenthesis.build()

      it "adds a parenthesis to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @manip.right_parenthesis.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.right_parenthesis).toBeTruthy()

    describe "DivisionCommand", ->
      it_plays_command_role (test)->
        test.manip.division.build()

      it "adds a division to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @manip.division.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.division).toBeTruthy()

    describe "PiCommand", ->
      it_plays_command_role (test)->
        test.manip.pi.build()

      it "adds a mulitplication and pi to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @manip.pi.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.pi).toBeTruthy()
        expect(new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    describe "SquareRootCommand", ->
      it_plays_command_role (test)->
        test.manip.square_root.build()

      it "finds the square root of an expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '4')
        ])
        new_exp = @manip.square_root.build().invoke(exp)
        expect(new_exp.last().value()).toEqual '2'


