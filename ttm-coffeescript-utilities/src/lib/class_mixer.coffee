ttm = thinkthroughmath

ttm.ClassMixer = ttm.class_mixer = (klass)->
  klass.build = ->
    it = new klass
    it.initialize && it.initialize.apply(it, arguments)
    it
  klass.prototype.klass = klass
  klass
