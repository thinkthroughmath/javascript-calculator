#= require lib/math/equation_checking
#= require lib/math/build_expression_from_javascript_object


#todo  go find a find json return results

# blank input "{"leftValue":null,"hasEqualsSign":false,"equationIsCorrect":false,"rightValue":null,"hasBothSides":false,"isEquationBlank":true,"hasAllKeyValues":false,"hasUnknown":false}"
# single number input "{"leftValue":null,"hasEqualsSign":false,"equationIsCorrect":false,"rightValue":null,"hasBothSides":false,"isEquationBlank":false,"hasAllKeyValues":false,"hasUnknown":false}"
# 96 = 96 "{"leftValue":null,"hasEqualsSign":true,"equationIsCorrect":false,"rightValue":null,"hasBothSides":true,"isEquationBlank":false,"hasAllKeyValues":false,"hasUnknown":false}"
# distianace / time = speed "{"leftValue":8,"hasEqualsSign":true,"equationIsCorrect":true,"rightValue":8,"hasBothSides":true,"isEquationBlank":false,"hasAllKeyValues":true,"hasUnknown":true}"
#

# current equation builder documentaiton:
# json that comes out:
# - leftValue
# - rightValue
# - hasEqualsSign
# - equationIsCorrect
# - hasBothSides
# - isEquationBlank
# - hasAllKeyValues
# - hasUnknown
#
# what is used by the app:
# - PSP.checkResponse uses
# - - equationIsCorrect
# - PSP.processStepThree uses
# - - equationIsCorrect
# - - hasEqualsSign
# - - hasUnknown

ttm = thinkthroughmath

describe "equation checking", ->
  beforeEach ->
    @math = ttm.lib.math.math_lib.build()
    @exp_manip = @math.commands
    @exp_pos_builder = @math.object_to_expression.buildExpressionPositionFunction()
    @eq_checker = @math.equation_checking

  describe "a base empty results case", ->
    beforeEach ->
      exp = @exp_pos_builder()
      vars = [{name: "doot"}, {name: "scoot"}]
      @checking = @eq_checker.build(exp, vars)
      json = @checking.asJSON()
      @parsed = JSON.parse(json)

    it "states that the equation is incorrect", ->
      expect(@checking.isCorrect()).toBeFalsy()

    it "returns json with equationIsCorrect set to false", ->
      expect(@parsed.equationIsCorrect).toEqual false

    it "returns json with hasEqualsSign set to false", ->
      expect(@parsed.hasEqualsSign).toEqual false

    it "returns json with hasUnknown set to false", ->
      expect(@parsed.hasUnknown).toEqual false

  describe "a basic, complete, correct case", ->
    beforeEach ->
      exp = @exp_pos_builder({variable: "doot"}, '=', {variable: 'scoot'})
      vars = [{name: "doot", value: 10, is_unknown: false}, {name: "scoot", value: 10, is_unknown: true}]
      @checking = @eq_checker.build(exp, vars)
      json = @checking.asJSON()
      @parsed = JSON.parse(json)

    it "states the equation is correct", ->
      expect(@checking.isCorrect()).toBeTruthy()

  describe "speed rate dist time case", ->
    it "works", ->
      vars = [{name: "time", value: "1.5"}, {name: "distance", value: "12"}, {name: "speed", value: "8", is_unknown: true}]
      exp = @exp_pos_builder({variable: "speed"}, '=', {variable: 'distance'}, '/', {variable: 'time'})
      @checking = @eq_checker.build(exp, vars)
      json = @checking.asJSON()
      @parsed = JSON.parse(json)
      expect(@checking.isCorrect()).toBeTruthy()
      expect(@checking.hasUnknown()).toEqual true


  describe "add and subtract decimals case", ->
    it "works", ->
      vars = [
        {name: "distance you ride", value: "3.5"}
        {name: "total distance", value: "5.6"}
        {name: "distance you walk", value: "2.1", is_unknown: true}
      ]
      exp = @exp_pos_builder({variable: "distance you walk"}, '=', {variable: 'total distance'}, '-', {variable: 'distance you ride'})
      @checking = @eq_checker.build(exp, vars)
      expect(@checking.isCorrect()).toBeTruthy()
      expect(@checking.hasUnknown()).toEqual true

  describe "operations with fractions case", ->
    it "works", ->
      vars = [
        {name: "Distance", value: "1/4"}
        {name: "Time", value: "2"}
        {name: "Speed", value: "1/8", is_unknown: true}
      ]
      exp = @exp_pos_builder({variable: "Speed"}, '=', {variable: 'Distance'}, '/', {variable: 'Time'})
      @checking = @eq_checker.build(exp, vars)
      expect(@checking.isCorrect()).toBeTruthy()
      expect(@checking.hasUnknown()).toEqual true



  describe "percent and percent change", ->
    it "works", ->
      vars = [
        {name: "price of bag in store", value: "32.75"}
        {name: "price of bag online", value: "41"}
        {name: "percent increase in bag price", value: "25.19", is_unknown: true}
      ]
      exp = @exp_pos_builder(
        [
          {variable: "price of bag online"}, '/'
          {variable: "price of bag in store"},
          '-', '1'
        ], '*', '100', '=',
        {variable: "percent increase in bag price"})

      @checking = @eq_checker.build(exp, vars)
      expect(@checking.isCorrect()).toBeTruthy()
      expect(@checking.hasUnknown()).toEqual true

  describe "solve two step equations", ->
    it "works", ->
      vars = [
        {name: "gas fee", value: "36"}
        {name: "daily rate", value: "34.95"}
        {name: "total cost", value: "210.75"}
        {name: "number of days", value: "5", is_unknown: true}
      ]
      exp = @exp_pos_builder(
        {variable: "daily rate"}, '*'
        {variable: "number of days"}, '+',
        {variable: "gas fee"},
        '=',
        {variable: "total cost"})

      @checking = @eq_checker.build(exp, vars)
      expect(@checking.isCorrect()).toBeTruthy()
      expect(@checking.hasUnknown()).toEqual true

  describe "when user tries to do 'unknown' = 'unknown'", ->
    it "rejects it", ->
      vars = [
        {name: "gas fee", value: "36"}
        {name: "daily rate", value: "34.95"}
        {name: "total cost", value: "210.75"}
        {name: "number of days", value: "5", is_unknown: true}
      ]
      exp = @exp_pos_builder(
        {variable: "number of days"},
        '=',
        {variable: "number of days"})

      @checking = @eq_checker.build(exp, vars)
      expect(@checking.isCorrect()).toBeFalsy()
      expect(@checking.hasUnknown()).toEqual true
