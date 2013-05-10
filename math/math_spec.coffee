#= require lib/math

expect_value = (expression, value)->
  expect(expression.display()).toEqual value

describe "Math Library", ->
  beforeEach ->
    @math = ttm.require('lib/math')

  describe "Equation", ->
    it "responds to last", ->
      eq = @math.equation.build()
      expect(eq.last()).toEqual null

    it "responds to append", ->
      eq = @math.equation.build()
      x = eq.append(@math.components.number.build(value: 10))
      expect(x.last().value()).toEqual '10'

    it "responds to replaceLast", ->
      tt = @math.components.number.build(value: '22')
      eq = @math.equation.build(@math.expression.buildWithContent [tt])
      x = eq.replaceLast(@math.components.number.build(value: '10'))
      expect(x.last().value()).toEqual '10'

  describe "Equation", ->
    it "responds to last", ->
      eq = @math.equation.build()
      expect(eq.last()).toEqual null

    it "responds to append", ->
      eq = @math.equation.build()
      x = eq.append(@math.components.number.build(value: 10))
      expect(x.last().value()).toEqual '10'

    it "responds to replaceLast", ->
      tt = @math.components.number.build(value: '22')
      eq = @math.equation.build(@math.expression.buildWithContent [tt])
      x = eq.replaceLast(@math.components.number.build(value: '10'))
      expect(x.last().value()).toEqual '10'

  describe "Expression", ->
    it "assigns components from its construtor", ->
      exp = @math.expression.build(
        expression: [
          @math.components.number.build(value: '10')
        ])
      expect_value(exp, '10')

  describe "expression components", ->
    describe "numbers", ->
      describe "negation", ->
        it "converts a number to a negative version", ->
          num = @math.components.number.build(value: 10)
          neg_num = num.negated()
          expect(neg_num.value()).toEqual("-10")

  describe "buttons", ->
    beforeEach ->
      @btn_lib = ttm.require 'lib/math/buttons'
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

