#= require lib/logger


LOGGING_TYPE="silent"
window.logger = switch LOGGING_TYPE
  when "silent" then window.ttm.Logger.buildSilent(stringify_objects: false)
  when "verbose" then window.ttm.Logger.buildVerbose(stringify_objects: false)
  else window.ttm.Logger.buildProduction(stringify_objects: false)
class_mixer = ttm.class_mixer

window.parseEntities = (str)-> $("<div>#{str}</div>").text()

jasmine.getFixtures().findContainer = ->
  $(document.body).find("##{@containerId}")

jasmine.getFixtures().getContainer = ->
  cont = @findContainer()
  if cont.length == 0
    @createContainer_("")
    cont = @findContainer()
  cont

window.f = (html="")->
  cont = jasmine.getFixtures().getContainer();
  if html.length > 0
    cont.html(html)
  cont

# method to assign a cursor to a js literal object
# used in equation builder
window.cursor = (thing)->
  thing.has_cursor = true
  thing


window.parsedDomText = (txt)->
  $("<p>#{txt}</p>").text()


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
        @check = ttm.require('lib/math/expression_equality').equalityCalculation(@actual, other)
        @check.isEqual()
      else
        false

  )


