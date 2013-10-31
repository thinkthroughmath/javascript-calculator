ttm = thinkthroughmath

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
      expression: @expr.clone()
      position: @pos
      type: @type_val
    other = @klass.build(_.extend({}, data, new_vals))
    other

  @buildExpressionPositionAsLast: (expression)->
    @build expression: expression, position:   expression.id()

ttm.lib.math.ExpressionPosition = ttm.class_mixer(ExpressionPosition)

