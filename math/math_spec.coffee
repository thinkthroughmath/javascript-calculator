#= require lib/math

describe "Math Library", ->
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


