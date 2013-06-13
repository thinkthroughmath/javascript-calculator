#= require lib/math/expression_traversal

class ExpressionTraversal
  initialize: (@expr)->

  findForID: (id, expr=@expr)->
    if "#{expr.id()}" == "#{id}" # is this it?
      return expr
    subexps = expr.subExpressions()
    for sub in subexps
      sub_search = @findForID(id, sub)
      if sub_search
        return sub_search
    return false

window.ttm.lib.math.ExpressionTraversal = ttm.class_mixer(ExpressionTraversal)
