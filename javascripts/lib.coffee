window.ttm ||= {}

ttm.ClassMixer = (klass)->
  klass.build = ->
    it = new klass
    it.initialize && it.initialize.apply(it, arguments)
    it
  klass
