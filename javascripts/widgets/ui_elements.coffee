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
          #{@wrappedMathTag("<mrow><mn>0</mn></mrow>")}
        </figure>
      """)
      opts.element.append @figure
      @figure

    wrappedMathTag: (content)->
      """
      <math xmlns=\"http://www.w3.org/1998/Math/MathML\">
        #{content}
      </math>
      """

    update: (mathml)->
      @mathml_renderer.render(@figure, @wrappedMathTag(mathml))

  class_mixer(MathMLDisplay)


  exports =
    button_builder: Button
    math_display_builder: MathDisplay
    mathml_display_builder: MathMLDisplay

  return exports

