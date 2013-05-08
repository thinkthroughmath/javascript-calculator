#= require almond_wrapper
#= require lib
#= require jquery
#= require widgets/mathml

ttm.define 'widgets/ui_elements', ['lib/class_mixer', 'widgets/mathml'], (class_mixer, mathml_renderer)->
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
      opts.element.append @figure
      @figure

    update: (value)->
      @figure.html(value)
  class_mixer(MathDisplay)

  class MathMLDisplay
    initialize: (@opts={})->
      @mathml_renderer = @opts.mathml_renderer || mathml_renderer
    render: (opts={})->
      opts = _.extend({}, @opts, opts)
      @figure = $("""
        <figure class='mathml-display #{opts.class}'>
          <math xmlns=\"http://www.w3.org/1998/Math/MathML\">
                  <mrow><mn>0</mn></mrow>
          </math>
        </figure>""")
      @math_element = @figure.find('math')
      opts.element.append @figure
      @figure

    update: (mathml)->
      #@math_element.html(mathml)

      @mathml_renderer.render(@math_element[0])


  class_mixer(MathMLDisplay)


  exports =
    button_builder: Button
    math_display_builder: MathDisplay
    mathml_display_builder: MathMLDisplay

  return exports

