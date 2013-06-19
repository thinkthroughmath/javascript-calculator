#= require almond_wrapper
#= require underscore-min
#= require lib/logger

window.AP = (object)->
  str = "#{object.constructor.name}"
  str += "{ "
  for key, value of object
    str += "#{key}: #{value}"
  str += " }"
  str
window.ttm ||= {}
window.ttm.dashboard ||= {}
window.ttm.decorators ||= {}
window.ttm.lib ||= {}

ttm.ClassMixer = ttm.class_mixer = (klass)->
  klass.build = ->
    it = new klass
    it.initialize && it.initialize.apply(it, arguments)
    it
  klass.prototype.klass = klass
  klass

ttm.define "lib/class_mixer", ->
  return ttm.ClassMixer


ttm.define "lib/historic_value", ->
  build = ->
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
  return build: build


# see the lib spec for example usage
ttm.define "lib/object_refinement", ['lib/class_mixer'], (class_mixer)->
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

  class_mixer Refinement

  class RefinementDeclaration
    initialize: (@methods)->
    apply: (subject)->
      refinement_class = ->
      refinement_class.prototype = subject
      ret = new refinement_class
      _.extend(ret, {unrefined: -> subject }, @methods)
      ret
  class_mixer RefinementDeclaration

  class RefinementByType extends RefinementDeclaration
    initialize: (@type, @methods)->

    isApplicable: (subject)->
      subject instanceof @type
  class_mixer RefinementByType


  return Refinement


ttm.defaults = (provided, defaults)->
  _.extend({}, defaults, provided)

