#= require lib/logger

ttm = thinkthroughmath

LOGGING_TYPE="silent"
window.logger = switch LOGGING_TYPE
  when "silent" then ttm.Logger.buildSilent(stringify_objects: false)
  when "verbose" then ttm.Logger.buildVerbose(stringify_objects: false)
  else ttm.Logger.buildProduction(stringify_objects: false)
class_mixer = ttm.class_mixer

(window || global).cursor = (thing)->
  thing.has_cursor = true
  thing

beforeEach ->
  @addMatchers(
    toBeInstanceOf: (type)->
      @message = ->
        if @actual == undefined
          "Expected undefined to be an instance of #{type.name}"
        else
          "Expected #{@actual.constructor.name}(#{jasmine.pp @actual}) to be an instance of #{type.name}"

      @actual && @actual instanceof type

    toBeAnEqualExpressionTo: (other)->
      @message = ->
        msg = "Expected #{@actual.toString()} to be equal to #{other.toString()}"
        if @check.report_saved
          msg += ", but failed on #{@check.a.toString()}, #{@check.b.toString()}, #{@check.not_eql_msg}"
        msg

      if @actual and other
        @check = ttm.lib.math.ExpressionEquality.equalityCalculation(@actual, other)
        @check.isEqual()
      else
        false

  )


