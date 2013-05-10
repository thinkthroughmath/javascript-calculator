#= require lib/math/expression_components
#= require lib/math/expression_equality



describe "expression equality", ->
  beforeEach ->
    @comps = ttm.require('lib/math/expression_components')
    @isEqual = ttm.require('lib/math/expression_equality').isEqual

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

    describe "checking against an expression", ->
      it "matches if the first element in the expression matches", ->
        expect(
          @isEqual(
            @comps.number.build(value: 10),
            @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ])
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


    describe "comparing an expression against non-expressions", ->
      it "accepts if the first part of the sub expression is equal to what it is comparing against ", ->
        expect(
          @isEqual(
            @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ]),
            @comps.number.build(value: 10)
          )).toEqual true

      it "rejects if the first part of the sub expression is not equal", ->
        expect(
          @isEqual(
            @comps.expression.build(expression: [
              @comps.number.build(value: 10)
              ]),
            @comps.number.build(value: 11)
          )).toEqual false

  describe "addition", ->
    it "accepts two addition symbols", ->
      expect(
        @isEqual(
          @comps.addition.build(),
          @comps.addition.build()
        )).toEqual true

