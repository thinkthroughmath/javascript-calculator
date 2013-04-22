#= require lib/math
#= require lib/math/buttons

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

describe "Math Library", ->
  beforeEach ->
    @math = ttm.require('lib/math')

  describe "Expression", ->
    it "assigns components from its construtor", ->
      exp = @math.expression.build(
        expression: [
          @math.components.number.build(value: '10')
        ])
      expect_value(exp, '10')

    it "sets an error state on an invalid expression", ->
      exp = @math.expression.build_with_content(
        [@math.components.division.build()]
      )
      new_exp = exp.calculate()
      expect(new_exp.isError()).toBeTruthy()

    describe "building from string", ->
      it "will build a number", ->
        @math.expression.build_from_string("1")

  describe "expression components", ->
    describe "numbers", ->
      describe "negation", ->
        it "converts a number to a negative version", ->
          num = @math.components.number.build(value: 10)
          neg_num = num.negated()
          expect(neg_num.value()).toEqual("-10")

  describe "expression commands", ->
    describe "the square command", ->
      beforeEach ->
        @square = @math.commands.square.build()

      it_plays_command_role (test)->
        test.square

      it "returns a squared expression", ->
        exp = @math.expression.build(
          expression: [
            @math.components.number.build(value: '10')
            ])

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
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])

        new_exp = @math.commands.multiplication.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.multiplication).toEqual true


    describe "SubtractionCommand", ->
      it_plays_command_role (test)->
        test.math.commands.subtraction.build()

      it "adds subtraction to the end of the expression", ->
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])

        new_exp = @math.commands.subtraction.build().invoke(exp)

        expect(new_exp.last() instanceof @math.components.subtraction).toEqual true

    describe "NegationCommand", ->
      it_plays_command_role (test)->
        test.math.commands.negation.build()

      it "will negate the last element", ->
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.negation.build().invoke(exp)
        expect(new_exp.last().value()).toEqual "-1"

    describe "LeftParenthesisCommand", ->
      beforeEach ->
        exp = @math.expression.build_with_content([
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
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.right_parenthesis.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.right_parenthesis).toBeTruthy()


    describe "DivisionCommand", ->
      it_plays_command_role (test)->
        test.math.commands.division.build()

      it "adds a division to the expression", ->
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.division.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.division).toBeTruthy()

    describe "PiCommand", ->
      it_plays_command_role (test)->
        test.math.commands.pi.build()

      it "adds a mulitplication and pi to the expression", ->
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '1')
        ])
        new_exp = @math.commands.pi.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.pi).toBeTruthy()
        expect(new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    describe "SquareRootCommand", ->
      it_plays_command_role (test)->
        test.math.commands.square_root.build()

      it "finds the square root of an expression", ->
        exp = @math.expression.build_with_content([
          @math.components.number.build(value: '4')
        ])
        new_exp = @math.commands.square_root.build().invoke(exp)
        expect(new_exp.last().value()).toEqual '2'

  describe "buttons", ->
    beforeEach ->
      @btn_lib = require 'lib/math/buttons'
      @buttons = @btn_lib.makeBuilder element: f()
    describe "variables", ->
      beforeEach ->
        @variable = {name: "face", variable_identifier: 124}
        @btn = @buttons.variables
          variables: [@variable]

      it "renders a set of variables", ->
        _(@btn).each (button)->
          button.render()
        expect(f().text()).toMatch /face/

      it "sends its passed object along to its clicked handler", ->
        spy = jasmine.createSpy('variable_btn_click')
        _(@btn).each (button)->
          button.render(click: spy)
        f().find('button').first().click()

        expect(spy.calls[0].args[0].variable).toEqual @variable

