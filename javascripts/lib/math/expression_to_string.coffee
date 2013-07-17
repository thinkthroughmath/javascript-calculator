ttm.define 'lib/math/expression_to_string',
  ['lib/class_mixer', 'lib/object_refinement'],
  (class_mixer, object_refinement)->

    class ExpressionToString
      initialize: (@expression_position, expression_contains_cursor)->
        @expression = @expression_position.expression()
        @position = @expression_position.position()
        @comps = ttm.lib.math.ExpressionComponentSource.build()
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
            ref.refine(@unrefined().base()).toString(include_parentheses_if_single: false)
          power: ->
            ref.refine(@unrefined().power()).toString(include_parentheses_if_single: true)
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
          toString: (opts={})->
            opts = @optsWithDefaults(opts)
            ret = @mapconcatWithMethod('toString', opts)
            @maybeWrapWithParentheses(ret, opts)

          toHTMLString: (opts={})->
            opts = @optsWithDefaults(opts)
            ret = @mapconcatWithMethod('toHTMLString', opts)
            @maybeWrapWithParentheses(ret, opts)

          mapconcatWithMethod: (method, opts)->
            _(@expression).map((it)-> ref.refine(it)[method]()).join(' ')

          maybeWrapWithParentheses: (str, opts)->
            if !opts.skip_parentheses # ie this is the "root" expression
              opening_paren = if (@expression.length > 1)
                "( "
              else if opts.include_parentheses_if_single and @expression.length == 1
                "( "
              else
                ""
              closing_paren =
                if expression_contains_cursor.isCursorWithinComponent(@)
                  ""
                else if @expression.length > 1
                  " )"
                else if opts.include_parentheses_if_single and @expression.length == 1
                  " )"
                else
                  ""
              "#{opening_paren}#{str}#{closing_paren}"
            else
              str

          decideWrap: (opts)->


          optsWithDefaults: (opts={})->
            ttm.defaults(opts, {skip_parentheses: false, include_parentheses_if_single: true})
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
        @ref.refine(@expression).toString(skip_parentheses: true)
      toHTMLString: ->
        @ref.refine(@expression).toHTMLString(skip_parentheses: true)

    class_mixer ExpressionToString

    ExpressionToString.toString = (expression_position, expression_contains_cursor)->
      ExpressionToString.build(expression_position, expression_contains_cursor).toString()

    ExpressionToString.toHTMLString = (expression_position, expression_contains_cursor)->
      ExpressionToString.build(expression_position, expression_contains_cursor).toHTMLString()
    ExpressionToString
