

ttm = thinkthroughmath

getComponentIDFromElement = (element)->
  classes = $(element).attr('class')
  split_classes = classes.split(' ')
  class_with_id = _(split_classes).find((css_class)->
    css_class.match /expression-component-id/
  )
  class_with_id && class_with_id.match(/(\d+)/)[1]


class MathMLCursorBlinkEmulator
  initialize: (@element)->
    @interval = 700
  start: ->
    @tick()
  tick: ->
    @element.find('.has-cursor-left.real-cursor').toggleClass('has-cursor-left-active')
    @element.find('.has-cursor-right.real-cursor').toggleClass('has-cursor-right-active')
    window.setTimeout((=> @tick()), @interval)

ttm.class_mixer(MathMLCursorBlinkEmulator)


class MathMLExpressionHandler

  @handle: (element, cursor_move_function, component_retriever, current_position)->
    expressions = element.find(".expression")
    expressions.each (i, exp)=>
      @build($(exp) , cursor_move_function, component_retriever, current_position).attach()
  initialize: (@element, @cursor_move_function, @component_retriever, @current_position)->

  expressionEndIndicator: ->
    if @element.hasClass 'is-root'
      @element.children(".position-move-target").last()
    else
      @element.children(".mo").last()

  attach: (options={})->
    component_id = getComponentIDFromElement(@element)
    component = @component_retriever.findForID(component_id)
    is_pointed_at = @current_position.isPointedAt(component)

    expression_end_element = @expressionEndIndicator()
    if is_pointed_at
      expression_end_element.length && expression_end_element.addClass('has-cursor-left real-cursor')

    expression_end_element.on "mouseenter mouseleave", ->
      expression_end_element.toggleClass('has-cursor-show-left')
      false

    expression_end_element.on "click", =>
      @cursor_move_function component_id, "inner"
      false

ttm.class_mixer(MathMLExpressionHandler)

class EquationBuilderRenderedMathMLModifier
  initialize: (@eq_comp_retriever,
    @expression_position_selected_function,
    @current_position_function, @element)->
    MathMLCursorBlinkEmulator.build(@element).start()

  afterUpdate: ()->
    current_position = @current_position_function()

    MathMLExpressionHandler.handle(
      @element,
      @expression_position_selected_function,
      @eq_comp_retriever,
      current_position
    )

ttm.class_mixer EquationBuilderRenderedMathMLModifier

ttm.widgets.EquationBuilderRenderedMathMLModifier = EquationBuilderRenderedMathMLModifier
