ttm.define "lib/math/expression_evaluation",
  ['lib/class_mixer', 'lib/object_refinement'],
  (class_mixer, object_refinement)->


    MalformedExpressionError = (message)->
      @name = 'MalformedExpressionError'
      @message = message
      @stack = (new Error()).stack
    MalformedExpressionError.prototype = new Error;

    comps = ttm.require("lib/math/expression_components")
    refinement = object_refinement.build()
    refinement.forType(comps.number,
      {
        eval: ->
          @  # a number returns itself when it evaluates
      });

    refinement.forType(comps.exponentiation,
      {
        eval: (evaluation, pass)->
          return if pass != "exponentiation"
          if @base() && @power()
            comps.number.build(value: Math.pow(@base().toCalculable(), @power().toCalculable()))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });

    refinement.forType(comps.expression,
      {
        eval: (evaluation, pass)->
          @first()
      });

    refinement.forType(comps.pi,
      {
        eval: ()->
          comps.number.build(value: Math.PI)
      });

    refinement.forType(comps.addition,
      {
        eval: (evaluation, pass)->
          return if pass != "addition"

          prev = evaluation.previousValue()
          next = evaluation.nextValue()
          if prev && next
            evaluation.handledSurrounding()
            comps.number.build(value: (parseFloat(prev) + parseFloat(next)))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });



    refinement.forType(comps.subtraction,
      {
        eval: (evaluation, pass)->
          return if pass != "addition"

          prev = evaluation.previousValue()
          next = evaluation.nextValue()
          if prev && next
            evaluation.handledSurrounding()
            comps.number.build(value: (parseFloat(prev) - parseFloat(next)))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });


    refinement.forType(comps.multiplication,
      {
        eval: (evaluation, pass)->
          return if pass != "multiplication"
          prev = evaluation.previousValue()
          next = evaluation.nextValue()
          if prev && next
            evaluation.handledSurrounding()
            comps.number.build(value: (parseFloat(prev) * parseFloat(next)))
          else
            throw new MalformedExpressionError("Invalid Expression")
      });



    refinement.forType(comps.division,
      {
        eval: (evaluation, pass)->
          return if pass != "multiplication"
          prev = evaluation.previousValue()
          next = evaluation.nextValue()
          if prev && next
            evaluation.handledSurrounding()
            comps.number.build(value: (parseFloat(prev) / parseFloat(next)))
          else
            throw new MalformedExpressionError("Invalid Expression")

      });

    refinement.forType(comps.left_parenthesis,
      {
        eval: (expression, pass)->
          return if pass != "parenthetical"
          subexpr = expression.subExpression()
          evaluated = subexpr.eval()
          subexpr.removeFromExpression()
          evaluated
      });


    refinement.forType(comps.right_parenthesis,
      {
        eval: (expression, pass)->
          throw new MalformedExpressionError("Parentheses mismatch")
      });

    class ExpressionEvaluation
      initialize: (@expression, @opts={})->
        @comps = @opts.comps || comps

      _calcResultingExpression: ->
        expr = @expression.expression
        expr = ExpressionEvaluationPass.build(expr).perform("parenthetical")
        expr = ExpressionEvaluationPass.build(expr).perform("exponentiation")
        expr = ExpressionEvaluationPass.build(expr).perform("multiplication")
        expr = ExpressionEvaluationPass.build(expr).perform("addition")
        eval_result = _(expr).first()
        new_content = if eval_result then [eval_result] else []
        new_exp = @comps.expression.buildWithContent new_content
        new_exp

      resultingExpression: ->
        try
          evaled = @_calcResultingExpression()
          evaled
        catch e
          if(e instanceof MalformedExpressionError)
            @comps.expression.buildError()
          else
            throw e

      resultingValue: ->
        item = @resultingExpression().first()
        if item then item.value() else @comps.number.build value: '0'

    class_mixer(ExpressionEvaluation)

    class ExpressionEvaluationPass
      initialize: (@expression)->
        @expression_index = -1

      perform: (pass_type)->
        ret = []

        @expression_index = 0
        while @expression.length > @expression_index
          exp = refinement.refine(@expression[@expression_index])
          eval_ret = exp.eval(@, pass_type)
          if eval_ret
            @expression[@expression_index] = eval_ret
          @expression_index += 1

        @expression

      previousValue: ->
        prev = @expression[@expression_index - 1]
        if prev
          prev.value()

      nextValue: ->
        next = @expression[@expression_index + 1]
        if next
          next.value()

      handledPrevious: ->
        @expression.splice(@expression_index - 1, 1)
        @expression_index -= 1

      handledSurrounding: ->
        @handledPrevious()
        @expression.splice(@expression_index + 1, 1)

      subExpression: ->
        new SubExpressionEvaluation(@expression, @expression_index + 1)

    class_mixer(ExpressionEvaluationPass)

    # TODO rewrite this in a functional style
    class SubExpressionEvaluation
      constructor: (@expression, @at)->
        @subexpression = @findSubexpression()

      findSubexpression: ->
        @i = @at
        found = false
        rparens_to_find = 1
        subexpression_parts = []
        while @i < @expression.length
          current = @expression[@i]
          if current instanceof comps.left_parenthesis
            rparens_to_find += 1 # we encountered another subexpression
          else if current instanceof comps.right_parenthesis
            rparens_to_find -= 1
            if rparens_to_find == 0
              found = true
              break
          else
            subexpression_parts.push(current)
          @i += 1
        if not found
          throw "There was a problem with your parentheses"
        else
          comps.expression.buildWithContent subexpression_parts

      removeFromExpression: ->
        removed = @expression.splice(@at, @i-@at+1)

      eval: ->
        ExpressionEvaluation.build(@subexpression).resultingExpression()

    return ExpressionEvaluation
