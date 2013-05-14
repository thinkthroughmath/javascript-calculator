ttm.define 'lib/math/expression_to_string',
  ['lib/class_mixer', 'lib/object_refinement', 'lib/math/expression_components'],
  (class_mixer, object_refinement, comps)->

    ref = object_refinement.build()
    ref.forDefault({
      toString: ->
        #console.log "toString not handled for #{AP @unrefined()}"
        "?"
      toHTMLString: ->
        #console.log "toHTMLString not handled for #{AP @unrefined()}"
        "?"
      })

    ref.forType(comps.addition, {
      toString: -> '+'
      toHTMLString: -> @toString()
      });

    ref.forType(comps.exponentiation, {
      base: ->
        ref.refine(@unrefined().base()).toString()
      power: ->
        ref.refine(@unrefined().power()).toString()
      toString: ->
        "#{@base()} ^ #{@power()}"
      toHTMLString: ->
        "#{@base()} &circ; #{@power()}"
      });

    ref.forType(comps.multiplication, {
      toString: ->
        "*"
      toHTMLString: ->
        "&times;"
      });

    ref.forType(comps.division, {
      toString: ->
        "/"
      toHTMLString: ->
        "&divide;"
      })

    ref.forType(comps.subtraction, {
      toString: ->
        "*"
      toHTMLString: ->
        "&times;"
      })

    ref.forType(comps.expression, {
      toString: (wrap_with_parentheses=true)->
        ret = @mapconcatWithMethod('toString')
        @maybeWrapWithParentheses(ret, wrap_with_parentheses)
      toHTMLString: (wrap_with_parentheses=true)->
        ret = @mapconcatWithMethod('toHTMLString')
        @maybeWrapWithParentheses(ret, wrap_with_parentheses)
      mapconcatWithMethod: (method)->
        _(@expression).map((it)-> ref.refine(it)[method]()).join(' ')
      maybeWrapWithParentheses: (str, do_wrap)->
        if do_wrap
          opening_paren = "( "
          closing_paren = if @isOpen() then "" else " )"
          "#{opening_paren}#{str}#{closing_paren}"
        else
          str
      });

    ref.forType(comps.blank, {
      toString: -> ""
      toHTMLString: -> ""
      })

    ref.forType(comps.number, {
      toString: ->
        "#{@val}"
      toHTMLString: ->
        "#{@val}"
      toDisplay: ->
        if @hasDecimal()
          @valueAtPrecision()
        else
          if @future_as_decimal
            "#{@val}."
          else
            "#{@val}"

      valueAtPrecision: ->
        number_decimal_places = 4
        parts = "#{@val}".split(".")
        if parts[1].length > number_decimal_places
          "#{((@val*1).toFixed(number_decimal_places) * 1)}"
        else
          "#{@val}"
      })

    class ExpressionToString
      initialize: (@expression)->
      toString: ->
        ref.refine(@expression).toString(false)
      toHTMLString: ->
        ref.refine(@expression).toHTMLString(false)

    class_mixer ExpressionToString

    ExpressionToString.toString = (expression)->
      ExpressionToString.build(expression).toString()

    ExpressionToString.toHTMLString = (expression)->
      ExpressionToString.build(expression).toHTMLString()
    ExpressionToString
