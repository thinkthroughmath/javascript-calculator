root = window || global

ttm = root.thinkthroughmath ||= {}
ttm.lib ||= {}


_ = require 'underscore'
require './lib/class_mixer'
require './lib/logger'
require './lib/polyfill'





ttm.defaults = (provided, defaults)->
  _.extend({}, defaults, provided)

ttm.logger ||= ttm.Logger.buildProduction(stringify_objects: false)

ttm.AP = (object)->
  str = "#{object.constructor.name}"
  str += "{ "
  for key, value of object
    str += "#{key}: #{value}"
  str += " }"
  str

ttm.dashboard ||= {}
ttm.decorators ||= {}





buildHistoricValue = ->
  values = []
  obj = {}
  obj.history = ->
    values
  obj.update = (val)->
    values.push val
  obj.current = ->
    values[values.length-1]

  # calls fn with current argument,
  # sets current value to return
  # value of the fn
  obj.updatedo = (fn)->
    values.push fn(obj.current())
  obj

ttm.lib.historic_value = build: buildHistoricValue




class Refinement
  initialize: ->
    @refinements = []

  forType: (type, methods)->

    @refinements.push RefinementByType.build(type, methods)

  forDefault: (methods)->
    @default_refinement = RefinementDeclaration.build(methods)

  refine: (component)->
    for refinement in @refinements
      if refinement.isApplicable(component)
        return refinement.apply(component)
    if @default_refinement
      @default_refinement.apply(component)
    else
      component

ttm.class_mixer Refinement

class RefinementDeclaration
  initialize: (@methods)->
  apply: (subject)->
    refinement_class = ->
    refinement_class.prototype = subject
    ret = new refinement_class
    _.extend(ret, {unrefined: -> subject }, @methods)
    ret
ttm.class_mixer RefinementDeclaration

class RefinementByType extends RefinementDeclaration
  initialize: (@type, @methods)->

  isApplicable: (subject)->
    subject instanceof @type

ttm.class_mixer RefinementByType

ttm.lib.object_refinement = Refinement



require './lib/math'


_.mixin {
  compactObject: (o) ->
    _.each o, (v, k) ->
      if(!v)
        delete o[k]
    o
}
