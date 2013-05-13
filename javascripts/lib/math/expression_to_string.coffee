ttm.define 'lib/math/expression_to_string',
  ['lib/class_mixer', 'lib/object_refinement', 'lib/math/expression_components'],
  (class_mixer, object_refinement, comps)->


    ref = object_refinement.build()

    ref.forDefault({
      toString: ->
        '?'
      toHTMLString: ->
        '?'
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
        "#{@base()}^#{@power()}"
      toHTMLString: ->
        "#{@base()}&circ;#{@power()}"
      });


    ref.forType(comps.expression, {
      toString: ->
        @mapconcatWithMethod('toString')
      toHTMLString: ->
        @mapconcatWithMethod('toHTMLString')
      mapconcatWithMethod: (method)->
        _(@expression).map((it)-> ref.refine(it)[method]()).join(' ')
      });

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
        ref.refine(@expression).toString()
      toHTMLString: ->
        ref.refine(@expression).toHTMLString()

    class_mixer ExpressionToString

    ExpressionToString.toString = (expression)->
      ExpressionToString.build(expression).toString()

    ExpressionToString.toHTMLString = (expression)->
      ExpressionToString.build(expression).toHTMLString()
    ExpressionToString
