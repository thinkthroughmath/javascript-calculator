#= require ./base


position_at_end = (expression)->
  expression.id()

class ExpressionPosition
  initialize: (opts={})->
    @expr = opts.expression
    @pos = opts.position
    @type_val = opts.type
  expression: -> @expr

  position: -> @pos

  type: -> @type_val

  isPointedAt: (expression_component)->
    "#{expression_component.id()}" == "#{@position()}"

  clone: (new_vals={})->
    data =
      expression: @expr
      position: @pos
      type: @type_val
    other = @klass.build(_.extend({}, data, new_vals))
    other


  @buildExpressionPositionAsLast: (expression)->
    @build expression: expression, position: position_at_end(expression)

ttm.lib.math.ExpressionPosition = ttm.class_mixer(ExpressionPosition)

