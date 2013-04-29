#= require almond_wrapper
#= require lib
#= require jquery


ttm.define 'widgets/ui_elements', ['lib/class_mixer', 'jquery'], (class_mixer, $)->
  class Button
    initialize: (@opts={})->
    render: (opts={})->
      opts = _.extend({}, @opts, opts)
      button = $("<button class='#{opts.class}' value='#{opts.value}'>#{opts.label || opts.value}</button>")
      button.click ->
        opts.click && opts.click(opts)
      opts.element.append button
  class_mixer(Button)
  return button_builder: Button

