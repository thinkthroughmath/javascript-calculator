ttm = thinkthroughmath

class ExpressionTraversal
  initialize: (@expr_classes, @expression_position)->
    @expr = @expression_position.expression()

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

  hasVariableNamed: (name)->
    found_equals = false
    @each (exp)=>
      found_equals = true if exp instanceof @expr_classes.variable and exp.name() == name
    found_equals

  buildExpressionComponentContainsCursor: ->
    ExpressionComponentContainsCursor.build(@expression_position, @)

ttm.class_mixer(ExpressionTraversal)

class ExpressionTraversalBuilder
  initialize: (@expression_component_classes)->
  build: (@expression_position)->
    ExpressionTraversal.build(@expression_component_classes, @expression_position)

ttm.class_mixer(ExpressionTraversalBuilder)

# class takes an ExpressionPosition object
# It can then tell via isCursorWithinComponent
# whether or not the current component "contains" the cursor
class ExpressionComponentContainsCursor
  initialize: (@expression_position, @traversal)->

  isCursorWithinComponent: (comp)->
    @componentIDsWithCursor().indexOf(comp.id()) != -1

  # privates below
  cursorComponent: ->
    @cursorComponent_val ||= @traversal.findForID(@expression_position.position())

  componentIDsWithCursor: ->
    if not @componentIDsWithCursor_val
      ids_with_cursor = []
      comp = @cursorComponent()
      while comp
        ids_with_cursor += comp.id()
        comp = comp.parent()
      @componentIDsWithCursor_val = ids_with_cursor
    @componentIDsWithCursor_val

ttm.class_mixer(ExpressionComponentContainsCursor)


ttm.lib.math.ExpressionTraversal = ttm.class_mixer(ExpressionTraversal)
ttm.lib.math.ExpressionTraversalBuilder = ttm.class_mixer(ExpressionTraversalBuilder)
