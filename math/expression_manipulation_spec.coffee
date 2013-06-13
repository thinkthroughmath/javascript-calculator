#= require lib/math/expression_manipulation
it_plays_manipulation_role = (options)->
  describe "acting as an expression manipulation", ->
    beforeEach ->
      @subject = options.subject.call(@)

    it "has a perform method", ->
      expect(typeof @subject.perform).toEqual "function"

    it "returns an ExpressionPosition object", ->
      orig = options.expression_for_performance.call(@)
      results = @subject.perform(orig)
      unless results instanceof ttm.lib.math.ExpressionPosition
        throw "The return value was not an instance of expression position"

it_inserts_component_into_the_last_nested_open_expression = (specifics)->
  it "adds #{specifics.name} to the deepest final open expression", ->
    @exp = @exp_builder(open_expression: {open_expression: []})
    exp = specifics.manipulator.call(@).perform(@exp)
    expected = specifics.should_equal_after(@exp_builder)
    expect(exp.expression).toBeAnEqualExpressionTo expected

describe "expression manipulations", ->
  beforeEach ->
    @components = ttm.lib.math.ExpressionComponentSource.build()
    @pos = ttm.lib.math.ExpressionPosition
    @manip = ttm.require('lib/math/expression_manipulation').build(@components, @pos)

    builder_lib = ttm.require('lib/math/build_expression_from_javascript_object')
    @exp_builder = builder_lib.build(@comps).builderFunction()
    @exp_pos_builder = builder_lib.build(@comps).builderFunctionExpressionWithPositionAsLast()
    expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(expression_to_string(expression)).toEqual value


  describe "a proof-of-concept example", ->
    it "produces the correct result TODO make this larger", ->
      exp = @exp_builder()
      position = ttm.lib.math.ExpressionPosition.build(position: exp.id(), expression: exp)

      exp = @manip.build_append_number(value: 1).perform(exp, position).expression
      exp = @manip.build_append_number(value: 0).perform(exp, position).expression
      exp = @manip.build_append_multiplication().perform(exp, position).expression

      exp = @manip.build_append_open_sub_expression().perform(exp, position).expression
      exp = @manip.build_append_number(value: 2).perform(exp, position).expression
      exp = @manip.build_append_addition().perform(exp, position).expression
      exp = @manip.build_append_number(value: 4).perform(exp, position).expression
      exp = @manip.build_close_sub_expression().perform(exp, position).expression

      expected = @exp_builder(10, '*', [2, '+', 4])
      expect(exp).toBeAnEqualExpressionTo expected


  describe "appending multiplication", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_multiplication()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "does nothing if the expression is empty", ->
      exp = @exp_builder()
      position = ttm.lib.math.ExpressionPosition.build(position: exp.id(), expression: exp)
      exp = @manip.build_append_multiplication().perform(exp, position).expression
      expected = @exp_builder()
      expect(exp).toBeAnEqualExpressionTo expected

    it "appends a multiplication", ->
      @exp = @exp_builder(10)

    it "adds multiplication to the end of the expression", ->
      exp = @exp_builder(1)
      results = @manip.build_append_multiplication().perform(exp)
      expect(results.expression.last() instanceof @components.classes.multiplication).toEqual true

    it "correctly adds multiplication to an exponentiation", ->
      exp = @exp_builder('^': [1, 2])
      new_exp = @manip.build_append_multiplication().perform(exp)
      expected = @exp_builder({'^': [1, 2]}, '*')
      expect(new_exp.expression).toBeAnEqualExpressionTo expected

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'multiplication'
      manipulator: -> @manip.build_append_multiplication()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['*']}))

  describe "exponentiate last element", ->
    describe "on a single number-only expression", ->
      beforeEach ->
        @new_exp = @manip.build_exponentiate_last().perform(@exp)

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.classes.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder([10]).first()

    describe "on an expression that currently ends with an operator ", ->
      it "replaces the trailing operator", ->
        exp = @exp_builder(10, '+')
        new_exp = @manip.build_exponentiate_last().perform(exp)
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "on an expression that has a trailing exponent", ->
      it "manipulates expression correctly", ->
        exp = @exp_builder('^': [10, {open_expression: null}])
        new_exp = @manip.build_exponentiate_last().perform(exp)
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

  describe "append number", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_number(value: 8)
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "inserts a number when the expression is empty", ->
      @exp_pos = @exp_pos_builder()
      exp = @manip.build_append_number(value: 8).perform(@exp_pos)
      expected = @exp_builder(8)
      expect(exp.expression()).toBeAnEqualExpressionTo expected

    describe "when the previous element is a closed expression", ->
      beforeEach ->
        @exp_pos = @exp_pos_builder([1])

      it "adds a multiplication symbol between elements", ->
        exp = @manip.build_append_number(value: 11).perform(@exp_pos)
        expected = @exp_builder([1], '*', 11)
        expect(exp.expression()).toBeAnEqualExpressionTo expected

  describe "append exponentiation", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_exponentiation()
      expression_for_performance: ->
        @exp_pos_builder(10)

    # this is x'd out because, for now, this should be failing
    # we need to fix later to get cursor-manipulation code that
    # is appropriate for the calculate and
    # gets rid of most of the concept of open expressions
    xdescribe "when the previous element is a nested open expression", ->
      beforeEach ->
        @exp_pos = @exp_pos_builder(open_expression: {open_expression: []})

      it "adds the number at the correct place", ->
        exp = @manip.build_append_number(value: 8).perform(@exp_pos.expression(), @exp_pos)
        expected = @exp_builder(open_expression: {open_expression: [8]})
        expect(exp.expression).toBeAnEqualExpressionTo expected

    describe "when the pointed-at element is an exponentiation ", ->
      # this is x'd out because, for now, this should be failing
      # we need to fix later to get cursor-manipulation code that
      # is appropriate for the calculate and
      # gets rid of most of the concept of open expressions
      xdescribe "with no power", ->
        beforeEach ->
          @exp = @exp_builder('^': [10, {open_expression:  null}])

        it "inserts the number into the exponentiation", ->
          new_exp = @manip.build_append_number(value: 11).perform(@exp)
          expected = @exp_builder('^': [10, {open_expression: 11}])
          expect(new_exp).toBeAnEqualExpressionTo expected

      describe "with a power", ->
        beforeEach ->
          @exp_pos = @exp_pos_builder('^': [10, 11])

        it "inserts a multiplication and then the number", ->
          new_exp = @manip.build_append_number(value: 7).perform(@exp_pos)
          expected = @exp_builder({'^': [10,11]}, '*', 7)
          expect(new_exp.expression()).toBeAnEqualExpressionTo expected

    describe "when the pointed-at element is a root", ->
      # this is x'd out because, for now, this should be failing
      # we need to fix later to get cursor-manipulation code that
      # is appropriate for the calculate and
      # gets rid of most of the concept of open expressions
      xit "inserts as root's radicand when radicand expression is open", ->
        @exp = @exp_builder('root': [10, {open_expression: null}])
        new_exp = @manip.build_append_number(value: 6).perform(@exp)
        expected = @exp_builder('root': [10, {open_expression: 6}])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "when the pointed at element is not one of those special cases", ->
      it "adds the number as a new number", ->
        exp_pos = @exp_pos_builder(1, '+', 3, '=')
        manipulated_exp = @manip.build_append_number(value: 8).perform(exp_pos)
        expected = @exp_builder(1, '+', 3, '=', 8)
        expect(manipulated_exp.expression()).toBeAnEqualExpressionTo expected


  describe "appending an equals", ->
    it "inserts an equals sign into the equation", ->
      @exp = @exp_builder(1, '+', 3)
      new_exp = @manip.build_append_equals().perform(@exp)
      expected = @exp_builder(1, '+', 3, '=')
      expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending a sub expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_open_sub_expression()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a sub-expression to the expression", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.build_append_open_sub_expression().perform(@exp)
      expected = @exp_builder(1, '+', {open_expression: []})
      expect(new_exp).toBeAnEqualExpressionTo expected

    it "adds an expression that isOpen", ->
      @exp = @exp_builder(1, '+')
      new_exp = @manip.build_append_open_sub_expression().perform(@exp)

      exp = new_exp.nth(2)
      expect(exp).toBeInstanceOf @components.classes.expression
      expect(exp.isOpen()).toEqual true

    describe "when adding to a sub-expression", ->
      it "should add everything correctly", ->
        exp = @exp_builder()
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_open_sub_expression().perform(exp)
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_open_sub_expression().perform(exp)
        exp = @manip.build_close_sub_expression().perform(exp)
        exp = @manip.build_close_sub_expression().perform(exp)
        expected = @exp_builder(6, '+', [6, '+', []])

        expect(exp).toBeAnEqualExpressionTo expected

  describe "closing a sub expression ", ->
    it "takes an open subexpression and closes it", ->
      exp = @exp_builder({open_expression: []})
      new_exp = @manip.build_close_sub_expression().perform(exp)
      expect(new_exp).toBeAnEqualExpressionTo @exp_builder([])

    it "correctly handles nested open subexpressions", ->
      exp = @exp_builder(open_expression: {open_expression: null})
      new_exp = @manip.build_close_sub_expression().perform(exp)
      expected = @exp_builder(open_expression: [[]])
      expect(new_exp).toBeAnEqualExpressionTo expected


  describe "appending division", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_division()

    it "adds a division to the expression", ->
      exp = @exp_builder(1)

      new_exp = @manip.build_append_division().perform(exp)
      expect(new_exp.last() instanceof @components.classes.division).toBeTruthy()


    it_inserts_component_into_the_last_nested_open_expression(
      name: 'division'
      manipulator: -> @manip.build_append_division()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['/']}))


  describe "appending addition", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_addition()

    it "adds addition to the end of the expression", ->
      exp = @exp_builder(1)
      new_exp = @manip.build_append_addition().perform(exp)
      expect(new_exp.last() instanceof @components.classes.addition).toEqual true

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'addition'
      manipulator: -> @manip.build_append_addition()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['+']}))



  describe "appending subtraction", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_subtraction()

    it "adds subtraction to the end of the expression", ->
      exp = @exp_builder(1)
      new_exp = @manip.build_append_subtraction().perform(exp)
      expect(new_exp.last() instanceof @components.classes.subtraction).toEqual true

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'subtraction'
      manipulator: -> @manip.build_append_subtraction()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['-']}))

  describe "appending a decimal", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_decimal(value: 5)

    it "correctly adds a decimal to the value", ->
      exp = @components.build_expression()
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_append_decimal().perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      @expect_value(exp, '1.1')

    it_inserts_component_into_the_last_nested_open_expression(
      name: 'decimal'
      manipulator: -> @manip.build_append_decimal()
      should_equal_after: (builder)-> builder(open_expression: {open_expression: ['0.']}))


  describe "square expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_square()

    it "returns a squared expression", ->
      exp = @exp_builder(10)
      squared = @manip.build_square().perform(exp)
      @expect_value(squared, '100')

  describe "AppendRoot", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_root()

    it "adds a mulitplication and root to the expression", ->
      exp = @exp_builder([1])

      new_exp = @manip.build_append_root(degree: 2).perform(exp)

      expect(new_exp.last() instanceof @components.classes.root).toBeTruthy()
      expect(new_exp.last(1) instanceof @components.classes.multiplication).toBeTruthy()

    it "adds a root with a radicand that is an open expression", ->
      exp = @exp_builder([1])

      new_exp = @manip.build_append_root(degree: 2).perform(exp)

      expect(new_exp.last() instanceof @components.classes.root).toBeTruthy()
      expect(new_exp.last().radicand().isOpen()).toBeTruthy()

  describe "AppendVariable", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_variable()

    it "adds itself to an empty expression", ->
      exp = @exp_builder()
      append_var = @manip.build_append_variable(variable: "doot")
      new_exp = append_var.perform(exp)
      expected = @exp_builder(variable: "doot")
      expect(new_exp).toBeAnEqualExpressionTo expected


  describe "Reset", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_reset()

      expression_for_performance: ->
        false # not important at all

    beforeEach ->
      @reset = @manip.build_reset()
      @result = @reset.perform()

    it "returns an empty resulting expression", ->
      expect(@result.expression()).toBeAnEqualExpressionTo @exp_builder()

    it "returns an pointer which points to that expression", ->
      expect(@result.position()).toEqual @result.expression().id()

  describe "update position", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_update_position()

      expression_for_performance: ->
        false


  describe "(moved over from other test file)", ->

    describe "NegationManipulation", ->
      it_plays_manipulation_role
        subject: ->
          @manip.build_negate_last()

      it "will negate the last element", ->
        exp = @exp_builder(1)
        new_exp = @manip.build_negate_last().perform(exp)
        expect(new_exp.last().value()).toEqual -1


    describe "AppendPi", ->
      it_plays_manipulation_role
        subject: ->
          @manip.build_append_pi()

      it "adds a mulitplication and pi to the expression", ->
        exp = @exp_builder(1)
        new_exp = @manip.build_append_pi().perform(exp)
        expect(new_exp.last() instanceof @components.classes.pi).toBeTruthy()
        expect(new_exp.last(1) instanceof @components.classes.multiplication).toBeTruthy()


    describe "SquareRootManipulation", ->
      it_plays_manipulation_role
        subject: ->
          @manip.build_square_root()

      it "finds the square root of an expression", ->
        exp = @exp_builder([4])
        new_exp = @manip.build_square_root().perform(exp)
        expect(new_exp.last().value()).toEqual '2'


