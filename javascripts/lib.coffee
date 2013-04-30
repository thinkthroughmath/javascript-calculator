#= require almond_wrapper
#= require underscore-min

window.ttm ||= {}
window.ttm.decorators ||= {}
window.ttm.lib ||= {}

ttm.ClassMixer = (klass)->
  klass.build = ->
    it = new klass
    it.initialize && it.initialize.apply(it, arguments)
    it
  klass.prototype.klass = klass
  klass


ttm.define "lib/class_mixer", ->
  return ttm.ClassMixer
