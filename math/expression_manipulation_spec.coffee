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

it_inserts_components_where_pointed_to = (specifics)->
  describe "#{specifics.name} inserts correctly when position is", ->
    it "works with a base case", ->
      start =
        if specifics.basic_start_expression
          specifics.basic_start_expression.call(@)
        else
          @exp_pos_builder()
      subject = specifics.subject.call(@)
      new_exp = subject.perform(start)
      expect(new_exp.expression()).toBeAnEqualExpressionTo(
       specifics.basic_should_equal_after.call(@)
      )



describe "expression manipulations", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @pos = @math.expression_position
    @manip = @math.commands
    @components = @math.components

    builder_lib = ttm.require('lib/math/build_expression_from_javascript_object')
    @exp_builder = @math.object_to_expression.builderFunction()
    @exp_pos_builder = @math.object_to_expression.builderFunctionExpressionWithPositionAsLast()
    expression_to_string = ttm.require('lib/math/expression_to_string').toString
    @expect_value = (expression, value)->
      expect(expression_to_string(expression)).toEqual value

  describe "a proof-of-concept example", ->
    it "produces the correct result TODO make this larger", ->
      exp = @exp_builder()
      exp_pos = ttm.lib.math.ExpressionPosition.build(position: exp.id(), expression: exp)
      exp_pos = @manip.build_append_number(value: 1).perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 0).perform(exp_pos)
      exp_pos = @manip.build_append_multiplication().perform(exp_pos)

      exp_pos = @manip.build_append_open_sub_expression().perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 2).perform(exp_pos)
      exp_pos = @manip.build_append_addition().perform(exp_pos)
      exp_pos = @manip.build_append_number(value: 4).perform(exp_pos)
      exp_pos = @manip.build_close_sub_expression().perform(exp_pos)

      expected = @exp_builder(10, '*', [2, '+', 4])
      expect(exp_pos.expression()).toBeAnEqualExpressionTo expected


  describe "appending multiplication", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_multiplication()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'multiplication'
      subject: -> @manip.build_append_multiplication()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '*'
    )

    it "does nothing if the expression is empty", ->
      exp_pos = @exp_pos_builder()
      exp_pos = @manip.build_append_multiplication().perform(exp_pos)
      expected = @exp_builder()
      expect(exp_pos.expression()).toBeAnEqualExpressionTo expected

    it "adds multiplication to the end of the expression", ->
      exp_pos = @exp_pos_builder(1)
      results = @manip.build_append_multiplication().perform(exp_pos)
      expect(results.expression().last() instanceof @components.classes.multiplication).toEqual true

    it "correctly adds multiplication to an exponentiation", ->
      exp_pos = @exp_pos_builder('^': [1, 2])
      new_exp = @manip.build_append_multiplication().perform(exp_pos)
      expected = @exp_builder({'^': [1, 2]}, '*')
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected



  describe "exponentiate last element", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_exponentiate_last()
      expression_for_performance: ->
        @exp_pos_builder()

    it_inserts_components_where_pointed_to(
      name: 'exponentiation'
      subject: -> @manip.build_exponentiate_last()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder '^': [1,{open_expression: null}]
    )


    describe "on a single number-only expression", ->
      beforeEach ->
        exp = @exp_pos_builder(10)
        @new_exp = @manip.build_exponentiate_last().perform(exp).expression()

      it "replaces the content of the expression with an exponentiation", ->
        expect(@new_exp.first()).toBeInstanceOf @components.classes.exponentiation

      it "provides the exponentiation its base", ->
        expect(@new_exp.first().base()).toBeAnEqualExpressionTo @exp_builder([10]).first()

    describe "on an expression that currently ends with an operator ", ->
      it "replaces the trailing operator", ->
        exp = @exp_pos_builder(10, '+')
        new_exp = @manip.build_exponentiate_last().perform(exp).expression()
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

    describe "on an expression that has a trailing exponent", ->
      it "manipulates expression correctly", ->
        exp = @exp_pos_builder('^': [10, {open_expression: null}])
        new_exp = @manip.build_exponentiate_last().perform(exp).expression()
        expected = @exp_builder('^': [10, {open_expression: null}])
        expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending a number", ->
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

  describe "appending exponentiation", ->
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
      @exp = @exp_pos_builder(1, '+', 3)
      new_exp = @manip.build_append_equals().perform(@exp).expression()
      expected = @exp_builder(1, '+', 3, '=')
      expect(new_exp).toBeAnEqualExpressionTo expected

  describe "appending a sub expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_open_sub_expression()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'appending a sub expression'
      subject: -> @manip.build_append_open_sub_expression()
      basic_start_expression: -> @exp_pos_builder()
      basic_should_equal_after: -> @exp_builder {open_expression: []}
    )

    it "adds a sub-expression to the expression", ->
      @exp = @exp_pos_builder(1, '+')
      new_exp = @manip.build_append_open_sub_expression().perform(@exp).expression()
      expected = @exp_builder(1, '+', {open_expression: []})
      expect(new_exp).toBeAnEqualExpressionTo expected

    it "adds an expression that isOpen", ->
      @exp = @exp_pos_builder(1, '+')
      new_exp = @manip.build_append_open_sub_expression().perform(@exp).expression()

      exp = new_exp.nth(2)
      expect(exp).toBeInstanceOf @components.classes.expression
      expect(exp.isOpen()).toEqual true

    describe "when adding to a sub-expression", ->
      it "should add everything correctly", ->
        exp = @exp_pos_builder()
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_open_sub_expression().perform(exp)
        exp = @manip.build_append_number(value: 6).perform(exp)
        exp = @manip.build_append_addition().perform(exp)

        exp = @manip.build_append_open_sub_expression().perform(exp)
        exp = @manip.build_close_sub_expression().perform(exp)
        exp = @manip.build_close_sub_expression().perform(exp)
        expected = @exp_builder(6, '+', [6, '+', []])

        expect(exp.expression()).toBeAnEqualExpressionTo expected

  describe "closing a sub expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_close_sub_expression()
      expression_for_performance: ->
        ret = @exp_pos_builder({open_expression: []})
        # we need to set the pointed position to the id of the open expression
        ret.clone(position: ret.expression().first().id())


    it_inserts_components_where_pointed_to(
      name: 'multiplication'
      subject: -> @manip.build_append_multiplication()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '*'
    )

    it "takes an open subexpression and closes it", ->
      exp = @exp_pos_builder({open_expression: []})
      exp = exp.clone position: exp.expression().first().id()

      new_exp = @manip.build_close_sub_expression().perform(exp)
      expect(new_exp.expression()).toBeAnEqualExpressionTo @exp_builder([])

    it "correctly handles closing a nested open subexpression that is pointed at", ->
      exp = @exp_pos_builder(open_expression: {open_expression: null})
      exp = exp.clone position: exp.expression().first().first().id()
      new_exp = @manip.build_close_sub_expression().perform(exp)
      expected = @exp_builder(open_expression: [[]])
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected


  describe "appending division", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_division()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a division to the expression", ->
      exp = @exp_pos_builder(1)

      new_exp = @manip.build_append_division().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.division).toBeTruthy()


    it_inserts_components_where_pointed_to(
      name: 'division'
      subject: -> @manip.build_append_division()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '/'
    )

    # it_inserts_component_into_the_last_nested_open_expression(
    #   name: 'division'
    #   manipulator: -> @manip.build_append_division()
    #   should_equal_after: (builder)-> builder(open_expression: {open_expression: ['/']}))


  describe "appending addition", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_addition()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'addition'
      subject: -> @manip.build_append_addition()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '+'
    )

    it "adds addition to the end of the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_addition().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.addition).toEqual true


  describe "appending subtraction", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_subtraction()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it_inserts_components_where_pointed_to(
      name: 'subtraction'
      subject: -> @manip.build_append_subtraction()
      basic_start_expression: -> @exp_pos_builder 1
      basic_should_equal_after: -> @exp_builder 1, '-'
    )


    it "adds subtraction to the end of the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_subtraction().perform(exp)
      expect(new_exp.expression().last() instanceof @components.classes.subtraction).toEqual true

  describe "appending a decimal", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_decimal(value: 5)
      expression_for_performance: ->
        @exp_pos_builder(10)


    it_inserts_components_where_pointed_to(
      name: 'append decimal'
      subject: -> @manip.build_append_decimal()
      basic_start_expression: -> @exp_pos_builder '1'
      basic_should_equal_after: -> @exp_builder '1.'
    )


    it "correctly adds a decimal to the value", ->
      exp = @exp_pos_builder()
      exp = @manip.build_append_number(value: 1).perform(exp)
      exp = @manip.build_append_decimal().perform(exp)
      exp = @manip.build_append_number(value: 1).perform(exp)
      @expect_value(exp.expression(), '1.1')

  describe "square expression", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_square()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "returns a squared expression", ->
      exp = @exp_pos_builder(10)
      squared = @manip.build_square().perform(exp)
      @expect_value(squared.expression(), '100')

  describe "AppendRoot", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_root()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a mulitplication and root to the expression", ->
      exp = @exp_pos_builder([1])

      new_exp = @manip.build_append_root(degree: 2).perform(exp).expression()

      expect(new_exp.last()).toBeInstanceOf @components.classes.root
      expect(new_exp.last(1)).toBeInstanceOf @components.classes.multiplication

  describe "AppendVariable", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_variable()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds itself to an empty expression", ->
      exp = @exp_pos_builder()
      new_exp = @manip.build_append_variable(variable: "doot").perform(exp)
      expected = @exp_builder(variable: "doot")
      expect(new_exp.expression()).toBeAnEqualExpressionTo expected


  describe "reset expression", ->
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
        @exp_pos_builder()


  describe "negate last", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_negate_last()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "will negate the last element", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_negate_last().perform(exp)
      expect(new_exp.expression().last().value()).toEqual -1

  describe "append pi", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_append_pi()

      expression_for_performance: ->
        @exp_pos_builder(10)

    it "adds a mulitplication and pi to the expression", ->
      exp = @exp_pos_builder(1)
      new_exp = @manip.build_append_pi().perform(exp).expression()
      expect(new_exp.last()).toBeInstanceOf @components.classes.pi
      expect(new_exp.last(1)).toBeInstanceOf @components.classes.multiplication


  describe "take the square root", ->
    it_plays_manipulation_role
      subject: ->
        @manip.build_square_root()
      expression_for_performance: ->
        @exp_pos_builder(10)

    it "finds the square root of an expression", ->
      exp = @exp_pos_builder([4])
      new_exp = @manip.build_square_root().perform(exp)
      expect(new_exp.expression().last().value()).toEqual '2'

  describe "utilities", ->
    describe "implicit multiplication", ->
      it "should have tests that go here", ->

    describe "expression manipulator", ->
      it "", ->



