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


expect_value = (expression, value)->
  expect(expression.display()).toEqual value

describe "expression manipulations", ->
  beforeEach ->
    @math = ttm.require('lib/math')
    @components = ttm.require('lib/math/expression_components')
    @manip = ttm.require('lib/math/expression_manipulation')
    @exp_builder = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression

  describe "exponentiate last element", ->
    describe "on a single number-only expression", ->
      beforeEach ->
        @exp = @exp_builder(10)
        @new_exp = @manip.exponentiate_last.build().invoke(@exp)

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder(10)


    describe "on an expression that currently is an addition", ->
      beforeEach ->
        @exp = @exp_builder(10)

      it "", ->

  describe "(moved over from other test file)", ->
    describe "the square command", ->
      beforeEach ->
        @square = @math.commands.square.build()

      it_plays_command_role (test)->
        test.square

      it "returns a squared expression", ->
        exp = @exp_builder(10)
        squared = @square.invoke(exp)
        expect_value(squared, '100')

    describe "the decimal command", ->
      it "correctly adds a decimal to the value", ->
        exp = @math.expression.build()
        exp = @math.commands.number.build(value: 1).invoke(exp)
        exp = @math.commands.decimal.build().invoke(exp)
        exp = @math.commands.number.build(value: 1).invoke(exp)
        expect_value(exp, '1.1')

    describe "NumberCommand", ->
      it_plays_command_role (test)->
        test.math.commands.number.build(value: 5)

    describe "DecimalCommand", ->
      it_plays_command_role (test)->
        test.math.commands.decimal.build(value: 5)


    describe "MultiplicationCommand", ->
      it_plays_command_role (test)->
        test.math.commands.multiplication.build()

      it "adds multiplication to the end of the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])

        new_exp = @math.commands.multiplication.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.multiplication).toEqual true


    describe "SubtractionCommand", ->
      it_plays_command_role (test)->
        test.math.commands.subtraction.build()

      it "adds subtraction to the end of the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])

        new_exp = @math.commands.subtraction.build().invoke(exp)

        expect(new_exp.last() instanceof @math.components.subtraction).toEqual true

    describe "NegationCommand", ->
      it_plays_command_role (test)->
        test.math.commands.negate_last.build()

      it "will negate the last element", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.negate_last.build().invoke(exp)
        expect(new_exp.last().value()).toEqual "-1"

    describe "LeftParenthesisCommand", ->
      beforeEach ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        @new_exp = @math.commands.left_parenthesis.build().invoke(exp)

      it_plays_command_role (test)->
        test.math.commands.left_parenthesis.build()

      it "adds a parenthesis to the expression", ->
        expect(@new_exp.last() instanceof @math.components.left_parenthesis).toBeTruthy()

      it "adds a multiplication to the expression when the previous item is a number", ->
        expect(@new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    describe "RightParenthesisCommand", ->
      it_plays_command_role (test)->
        test.math.commands.right_parenthesis.build()

      it "adds a parenthesis to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.right_parenthesis.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.right_parenthesis).toBeTruthy()


    describe "DivisionCommand", ->
      it_plays_command_role (test)->
        test.math.commands.division.build()

      it "adds a division to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.division.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.division).toBeTruthy()

    describe "PiCommand", ->
      it_plays_command_role (test)->
        test.math.commands.pi.build()

      it "adds a mulitplication and pi to the expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.pi.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.pi).toBeTruthy()
        expect(new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    describe "SquareRootCommand", ->
      it_plays_command_role (test)->
        test.math.commands.square_root.build()

      it "finds the square root of an expression", ->
        exp = @math.expression.buildWithContent([
          @math.components.number.build(value: '4')
        ])
        new_exp = @math.commands.square_root.build().invoke(exp)
        expect(new_exp.last().value()).toEqual '2'


