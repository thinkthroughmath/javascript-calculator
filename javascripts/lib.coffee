#= require almond

window.ttm ||= {}

ttm.ClassMixer = (klass)->
  klass.build = ->
    it = new klass
    it.initialize && it.initialize.apply(it, arguments)
    it
  klass.prototype.klass = klass
  klass


define "lib/class_mixer", ->
  return ttm.ClassMixer
