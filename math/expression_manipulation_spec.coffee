#= require lib/math/expression_manipulation



it_plays_manipulation_role = (subject, math)->
  describe "acting as an expression manipulation", ->
    beforeEach ->
      @subject = subject.call(@)

    it "has an invoke method", ->
      expect(typeof @subject.invoke).toEqual "function"

    it "returns an expression", ->
      ret = @subject.invoke(@math.expression.build())
      unless ret instanceof @math.expression
        throw "The return value was not an instance of expression"

it_inserts_component_into_the_last_nested_open_expression = (specifics)->
  it "adds #{specifics.name} to the deepest final open expression", ->
    @exp = @exp_builder(open_expression: {open_expression: []})
    exp = specifics.manipulator.call(@).invoke(@exp)
    expected = specifics.should_equal_after(@exp_builder)
    expect(exp).toBeAnEqualExpressionTo expected

describe "expression manipulations", ->
  beforeEach ->
    @math = ttm.require('lib/math')
    @components = ttm.require('lib/math/expression_components')
    @manip = ttm.require('lib/math/expression_manipulation')
    @exp_builder = ttm.require('lib/math/build_expression_from_javascript_object').buildExpression
    @expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(@expression_to_string(expression)).toEqual value

  describe "a proof-of-concept example", ->
    it "produces the correct result TODO make this larger", ->
      exp = @exp_builder()
      exp = @manip.append_number.build(value: 1).invoke(exp)
      exp = @manip.append_number.build(value: 0).invoke(exp)
      exp = @manip.append_multiplication.build().invoke(exp)
      exp = @manip.open_sub_expression.build().invoke(exp)
      exp = @manip.append_number.build(value: 2).invoke(exp)
      exp = @manip.append_addition.build().invoke(exp)
      exp = @manip.append_number.build(value: 4).invoke(exp)
      exp = @manip.close_sub_expression.build().invoke(exp)
      expected = @exp_builder(10, '*', [2, '+', 4])
      expect(exp).toBeAnEqualExpressionTo expected

  describe "exponentiate last element", ->
    describe "on a single number-only expression", ->
      beforeEach ->
        @exp = @exp_builder(10)
        @new_exp = @manip.exponentiate_last.build().invoke(@exp)

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder([10]).first()

    describe "on an expression that currently ends with an operator ", ->
      it "replaces the trailing operator", ->
        exp = @exp_builder(10, '+')
        new_exp = @manip.exponentiate_last.build().invoke(exp)
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "on an expression that has a trailing exponent", ->
      it "manipulates expression correctly", ->
        exp = @exp_builder('^': [10, {open_expression: null}])
        new_exp = @manip.exponentiate_last.build().invoke(exp)
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

  describe "append number", ->
    describe "when the previous element is a closed expression", ->
      beforeEach ->
        @exp = @exp_builder([1])

      it "adds a multiplication symbol between elements", ->
        exp = @manip.append_number.build(value: 11).invoke(@exp)
        expected = @exp_builder([1], '*', 11)
        expect(exp).toBeAnEqualExpressionTo expected

    describe "when the previous element is a nested open expression", ->
      beforeEach ->
        @exp = @exp_builder(open_expression: {open_expression: []})

      it "adds the number at the correct place", ->
        exp = @manip.append_number.build(value: 8).invoke(@exp)
        expected = @exp_builder(open_expression: {open_expression: [8]})
        expect(exp).toBeAnEqualExpressionTo expected

    describe "when the previous element is an exponentiation ", ->
      describe "with no power", ->
        beforeEach ->
          @exp = @exp_builder('^': [10, {open_expression:  null}])

        it "inserts the number into the exponentiation", ->
          new_exp = @manip.append_number.build(value: 11).invoke(@exp)
          expected = @exp_builder('^': [10, {open_expression: 11}])
          expect(new_exp).toBeAnEqualExpressionTo expected

      describe "with a power", ->
        beforeEach ->
          @exp = @exp_builder('^': [10, 11])

        it "inserts a multiplication and then the number", ->
          new_exp = @manip.append_number.build(value: 7).invoke(@exp)
          expected = @exp_builder({'^': [10,11]}, '*', 7)
          expect(new_exp).toBeAnEqualExpressionTo expected

    describe "when the previous element is a root", ->
      it "inserts as root's radicand when radicand expression is open", ->
        @exp = @exp_builder('root': [10, {open_expression: null}])
        new_exp = @manip.append_number.build(value: 6).invoke(@exp)
        expected = @exp_builder('root': [10, {open_expression: 6}])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "when the prevous element is none of the other special cases", ->
      it "adds the number as a new number", ->
        exp = @exp_builder(1, '+', 3, '=')
        manipulated_exp = @manip.append_number.build(value: 8).invoke(exp)
        expected = @exp_builder(1, '+', 3, '=', 8)
        expect(manipulated_exp).toBeAnEqualExpressionTo expected


  describe "appending an equals", ->
    it "inserts an equals sign into the equation", ->
      @exp = @exp_builder(1, '+', 3)
      new_exp = @manip.append_equals.build().invoke(@exp)
      expected = @exp_builder(1, '+', 3, '=')
      expect(new_exp).toBeAnEqualExpressionTo expected

  describe "opening a new sub expression", ->
    it "adds a sub-expression to the expression", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.open_sub_expression.build().invoke(@exp)
      expected = @exp_builder(1, '+', {open_expression: []})
      expect(new_exp).toBeAnEqualExpressionTo expected

    it "adds an expression that isOpen", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.open_sub_expression.build().invoke(@exp)

      exp = new_exp.nth(2)
      expect(exp).toBeInstanceOf @math.components.expression
      expect(exp.isOpen()).toEqual true

    describe "when adding to a sub-expression", ->
      it "should add everything correctly", ->
        exp = @exp_builder()
        exp = @manip.append_number.build(value: 6).invoke(exp)
        exp = @manip.append_addition.build().invoke(exp)

        exp = @manip.open_sub_expression.build().invoke(exp)
        exp = @manip.append_number.build(value: 6).invoke(exp)
        exp = @manip.append_addition.build().invoke(exp)

        exp = @manip.open_sub_expression.build().invoke(exp)
        exp = @manip.close_sub_expression.build().invoke(exp)
        exp = @manip.close_sub_expression.build().invoke(exp)
        expected = @exp_builder(6, '+', [6, '+', []])

        expect(exp).toBeAnEqualExpressionTo expected

  describe "closing a sub expression ", ->
    it "takes an open subexpression and closes it", ->
      exp = @exp_builder({open_expression: []})
      new_exp = @manip.close_sub_expression.build().invoke(exp)
      expect(new_exp).toBeAnEqualExpressionTo @exp_builder([])

    it "correctly handles nested open subexpressions", ->
      exp = @exp_builder(open_expression: {open_expression: null})
      new_exp = @manip.close_sub_expression.build().invoke(exp)
      expected = @exp_builder(open_expression: [[]])
      expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending multiplication", ->
    it_plays_manipulation_role (test)->
      @manip.append_multiplication.build()

    it "adds multiplication to the end of the expression", ->
      exp = @exp_builder(1)
      new_exp = @manip.append_multiplication.build().invoke(exp)
      expect(new_exp.last() instanceof @math.components.multiplication).toEqual true

    it "correctly adds multiplication to an exponentiation", ->
      exp = @exp_builder('^': [1, 2])
      new_exp = @manip.append_multiplication.build().invoke(exp)
      expected = @exp_builder({'^': [1, 2]}, '*')
      expect(new_exp).toBeAnEqualExpressionTo expected

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'multiplication'
      manipulator: -> @manip.append_multiplication.build()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['*']}))

  describe "appending division", ->
    it_plays_manipulation_role (test)->
      @manip.append_division.build()

    it "adds a division to the expression", ->
      exp = @exp_builder(1)

      new_exp = @manip.append_division.build().invoke(exp)
      expect(new_exp.last() instanceof @math.components.division).toBeTruthy()

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'division'
      manipulator: -> @manip.append_division.build()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['/']}))


  describe "appending addition", ->
    it_plays_manipulation_role (test)->
      @manip.append_addition.build()

    it "adds addition to the end of the expression", ->
      exp = @exp_builder(1)
      new_exp = @manip.append_addition.build().invoke(exp)
      expect(new_exp.last() instanceof @math.components.addition).toEqual true

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'addition'
      manipulator: -> @manip.append_addition.build()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['+']}))



  describe "appending subtraction", ->
    it_plays_manipulation_role (test)->
      @manip.append_subtraction.build()

    it "adds subtraction to the end of the expression", ->
      exp = @exp_builder(1)
      new_exp = @manip.append_subtraction.build().invoke(exp)
      expect(new_exp.last() instanceof @math.components.subtraction).toEqual true

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'subtraction'
      manipulator: -> @manip.append_subtraction.build()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['-']}))

  describe "appending a decimal", ->
    it_plays_manipulation_role ->
      @manip.append_decimal.build(value: 5)

    it "correctly adds a decimal to the value", ->
      exp = @math.expression.build()
      exp = @manip.append_number.build(value: 1).invoke(exp)
      exp = @manip.append_decimal.build().invoke(exp)
      exp = @manip.append_number.build(value: 1).invoke(exp)
      @expect_value(exp, '1.1')

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'decimal'
      manipulator: -> @manip.append_decimal.build()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['0.']}))


  describe "square expression", ->
    beforeEach ->
      @square = @manip.square.build()

    it_plays_manipulation_role (test)->
      @square

    it "returns a squared expression", ->
      exp = @exp_builder(10)
      squared = @square.invoke(exp)
      @expect_value(squared, '100')

  describe "AppendRoot", ->
    it_plays_manipulation_role ->
      @manip.append_root.build()

    it "adds a mulitplication and root to the expression", ->
      exp = @exp_builder([1])

      new_exp = @manip.append_root.build(degree: 2).invoke(exp)

      expect(new_exp.last() instanceof @math.components.root).toBeTruthy()
      expect(new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()

    it "adds a root with a radicand that is an open expression", ->
      exp = @exp_builder([1])

      new_exp = @manip.append_root.build(degree: 2).invoke(exp)

      expect(new_exp.last() instanceof @math.components.root).toBeTruthy()
      expect(new_exp.last().radicand().isOpen()).toBeTruthy()

  describe "AppendVariable", ->
    it_plays_manipulation_role ->
      @manip.append_variable.build()

    it "adds itself to an empty expression", ->
      exp = @exp_builder()
        append_var = @manip.append_variable.build(variable: "doot")
      new_exp = append_var.invoke(exp)
      expected = @exp_builder(variable: "doot")
      expect(new_exp).toBeAnEqualExpressionTo expected


  describe "(moved over from other test file)", ->
    describe "NumberManipulation", ->
      it_plays_manipulation_role (test)->
        @manip.append_number.build(value: 5)

    describe "NegationManipulation", ->
      it_plays_manipulation_role (test)->
        @manip.negate_last.build()

      it "will negate the last element", ->
        exp = @exp_builder(1)
        new_exp = @manip.negate_last.build().invoke(exp)
        expect(new_exp.last().value()).toEqual -1


    describe "AppendPi", ->
      it_plays_manipulation_role (test)->
        @manip.append_pi.build()

      it "adds a mulitplication and pi to the expression", ->
        exp = @exp_builder(1)
        new_exp = @manip.append_pi.build().invoke(exp)
        expect(new_exp.last() instanceof @math.components.pi).toBeTruthy()
        expect(new_exp.last(1) instanceof @math.components.multiplication).toBeTruthy()


    describe "SquareRootManipulation", ->
      it_plays_manipulation_role (test)->
        @manip.square_root.build()

      it "finds the square root of an expression", ->
        exp = @exp_builder([4])
        new_exp = @manip.square_root.build().invoke(exp)
        expect(new_exp.last().value()).toEqual '2'


