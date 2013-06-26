#= require lib/math/expression_traversal

class ExpressionTraversal
  initialize: (@expr_classes, @expr)->

  each: (fn, expr=@expr)->
    fn(expr)
    subexps = expr.subExpressions()
    for sub in subexps
      @each(fn, sub)

  findForID: (id)->
    found = false
    @each (exp)->
      found = exp if "#{exp.id()}" == "#{id}"
    found

  hasEquals: ->
    found_equals = false
    @each (exp)=>
      found_equals = true if exp instanceof @expr_classes.equals
    found_equals

ttm.class_mixer(ExpressionTraversal)

class ExpressionTraversalBuilder
  initialize: (@expression_component_classes)->
  build: (@expression)->
    ExpressionTraversal.build(@expression_component_classes, @expression)
ttm.class_mixer(ExpressionTraversal)


window.ttm.lib.math.ExpressionTraversal = ttm.class_mixer(ExpressionTraversal)
window.ttm.lib.math.ExpressionTraversalBuilder = ttm.class_mixer(ExpressionTraversalBuilder)
