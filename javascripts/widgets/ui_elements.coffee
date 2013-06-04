#= require almond_wrapper
#= require lib
#= require jquery

ttm.define 'widgets/ui_elements', ['lib/class_mixer'], (class_mixer)->
  class Button
    initialize: (@opts={})->
    render: (opts={})->
      opts = _.extend({}, @opts, opts)
      button = $("<button class='#{opts.class}' value='#{opts.value}'>#{opts.label || opts.value}</button>")
      button.click ->
        opts.click && opts.click(opts)
      opts.element.append button
  class_mixer(Button)

  class MathDisplay
    initialize: (@opts={})->
    render: (opts={})->
      opts = _.extend({},@opts, opts)
      @figure = $("<figure class='math-display #{opts.class}'>#{opts.default || '0'}</figure>")
      opts.element.append(@figure)
      @figure
    update: (value)->
      @figure.html(value)
  class_mixer(MathDisplay)

  exports =
    button_builder: Button
    math_display_builder: MathDisplay

  return exports

