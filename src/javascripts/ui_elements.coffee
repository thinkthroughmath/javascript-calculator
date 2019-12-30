ttm = thinkthroughmath

class Button
  initialize: (@opts={})->
  render: (opts={})->
    opts = _.extend({}, @opts, opts)
    button = $("""
      <button type='button' class='#{opts.class}' value='#{opts.value}' aria-label='#{opts.ariaLabel}'>
        <span class="jc--buttonLabel">
          #{opts.label || opts.value}
        </span>
      </button>
    """)
    button.on "click", ->
      opts.click && opts.click(opts)
    opts.element.append button
ttm.class_mixer(Button)

class MathDisplay
  initialize: (@opts={})->
  render: (opts={})->
    opts = _.extend({},@opts, opts)
    @figure = $("<figure class='math-display #{opts.class}'>#{opts.default || '0'}</figure>")
    opts.element.append(@figure)
    @figure
  update: (value)->
    @figure.html(value)
ttm.class_mixer(MathDisplay)

class UIElements
  button_builder: Button
  math_display_builder: MathDisplay

ttm.widgets.UIElements = ttm.class_mixer(UIElements)
