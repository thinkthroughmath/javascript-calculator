# a really simple library for
# doing "precise" js math
#
# tactic
# limits the max value of numbers
# but makes floats precise, which is what we want.


ttm = thinkthroughmath


factor = 10000000
class Precise
  initialize: (@adjustment_factor=factor)->

  convertInternal: (val)->
    parseInt((parseFloat(val) * @adjustment_factor).toFixed())

  convertExternal: (val)->
    "#{val / @adjustment_factor}"

  convertExternal2: (val)->
    "#{val / (@adjustment_factor * @adjustment_factor)}"

  sub: (a, b)->
    @wc a, b, (a, b)->
      a - b
  add: (a, b)->
    @wc a, b, (a, b)->
      a + b

  mul: (a, b)->
    @wc2 a, b, (a, b)->
      a * b

  div: (a, b)->
    @wc0 a, b, (a, b)->
      a / b

  # with conversions
  wc: (a, b, fn)->
    ac = @convertInternal(a)
    bc = @convertInternal(b)
    @convertExternal(fn(ac, bc))

  # with conversions 2, contains factor squared
  wc2: (a, b, fn)->
    ac = @convertInternal(a)
    bc = @convertInternal(b)
    @convertExternal2(fn(ac, bc))

  # with conversions 0, does not need any dividing to convert back
  wc0: (a, b, fn)->
    ac = @convertInternal(a)
    bc = @convertInternal(b)
    "#{fn(ac, bc)}"


ttm.lib.math.Precise = ttm.class_mixer Precise
