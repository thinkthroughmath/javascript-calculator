ttm.define 'lib/math/expression_to_string',
  ['lib/class_mixer', 'lib/object_refinement'],
  (class_mixer, object_refinement)->

    class ExpressionToString
      initialize: (@expression, @comps)->
        @comps ||= ttm.lib.math.ExpressionComponentSource.build()
        comps = @comps

        @ref = ref = object_refinement.build()
        ref.forDefault({
          toString: ->
            #console.log "toString not handled for #{AP @unrefined()}"
            "?"
          toHTMLString: ->
            #console.log "toHTMLString not handled for #{AP @unrefined()}"
            "?"
          })

        ref.forType(comps.classes.addition, {
          toString: -> '+'
          toHTMLString: -> @toString()
          });

        ref.forType(comps.classes.exponentiation, {
          base: ->
            ref.refine(@unrefined().base()).toString()
          power: ->
            ref.refine(@unrefined().power()).toString()
          toString: ->
            "#{@base()} ^ #{@power()}"
          toHTMLString: ->
            "#{@base()} &circ; #{@power()}"
          });

        ref.forType(comps.classes.multiplication, {
          toString: ->
            "*"
          toHTMLString: ->
            "&times;"
          });

        ref.forType(comps.classes.division, {
          toString: ->
            "/"
          toHTMLString: ->
            "&divide;"
          })

        ref.forType(comps.classes.subtraction, {
          toString: ->
            "*"
          toHTMLString: ->
            "&times;"
          })

        ref.forType(comps.classes.expression, {
          toString: (wrap_with_parentheses=true)->
            ret = @mapconcatWithMethod('toString')
            @maybeWrapWithParentheses(ret, wrap_with_parentheses)

          toHTMLString: (wrap_with_parentheses=true)->
            ret = @mapconcatWithMethod('toHTMLString')
            @maybeWrapWithParentheses(ret, wrap_with_parentheses)

          mapconcatWithMethod: (method)->
            _(@expression).map((it)-> ref.refine(it)[method]()).join(' ')

          maybeWrapWithParentheses: (str, do_wrap)->
            if do_wrap and @decideWrap()
              opening_paren = "( "
              closing_paren = if @isOpen() then "" else " )"
              "#{opening_paren}#{str}#{closing_paren}"
            else
              str

          decideWrap: ->
            @expression.length > 1

          });

        ref.forType(comps.classes.blank, {
          toString: -> ""
          toHTMLString: -> ""
          })

        ref.forType(comps.classes.number, {
          toString: ->
            @toDisplay()
          toHTMLString: ->
            @toDisplay()
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

      toString: ->
        @ref.refine(@expression).toString(false)
      toHTMLString: ->
        @ref.refine(@expression).toHTMLString(false)

    class_mixer ExpressionToString

    ExpressionToString.toString = (expression)->
      ExpressionToString.build(expression).toString()

    ExpressionToString.toHTMLString = (expression)->
      ExpressionToString.build(expression).toHTMLString()
    ExpressionToString
