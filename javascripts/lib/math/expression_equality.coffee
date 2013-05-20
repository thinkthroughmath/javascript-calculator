#= require lib
#= require lib/logger
#= require lib/math/expression_components
#= require lib/math/expression_equality
#= require almond_wrapper

ttm.define 'lib/math/expression_equality',
  ['lib/class_mixer', 'lib/object_refinement', 'lib/math/expression_components', 'logger'],
  (class_mixer, object_refinement, comps, logger_builder)->
    ref = object_refinement.build()

    logger = logger_builder.build(stringify_objects: false)

    buildIsEqual = (for_type)->
      x = (other)->
        if other instanceof for_type
          if @_simpleIsEqual
            @_simpleIsEqual(other)
          else
            true
        else if other instanceof comps.expression
          ref.refine(other).isEqual @
        else
          false
      logger.instrument(name: "buildIsEqual function", fn: x)

    ref.forType(comps.expression, {
      isExpressionEqual: (other)->
        logger.info("isExpressionEqual", @unrefined(), other)
        if @is_error == other.is_error && @is_open == other.is_open
          if _(@expression).size() == _(other.expression).size()
            contains_unequal =
              _.chain(@expression).map((element, i)->
                ref.refine(element).isEqual(other.nth(i))
              ).contains(false).value()
            !contains_unequal
          else
            false
        else
          false

      isEqual: (other)->
        if other instanceof comps.expression
          @isExpressionEqual(other)
    })

    ref.forType(comps.number, {
      isEqual: (buildIsEqual(comps.number)),
      _simpleIsEqual: (other)->
        # this is bad; TODO fix
        # The real "todo" here is that
        # numbers are internally of questionable state.
        # Im not entirely sure how to state that number expresison components are equal
        "#{@value()}" == "#{other.value()}"
    })

    ref.forType(comps.addition, {
      isEqual: (buildIsEqual(comps.addition))
      })

    ref.forType(comps.multiplication, {
      isEqual: (buildIsEqual(comps.multiplication))
      })


    ref.forType(comps.blank, {
      isEqual: (buildIsEqual(comps.blank))
      })

    ref.forType(comps.exponentiation, {
      isEqual: (buildIsEqual(comps.exponentiation)),
      _simpleIsEqual: (other)->
        ref.refine(@base()).isEqual(other.base()) and
          ref.refine(@power()).isEqual(other.power())
      })

    ref.forDefault({
      isEqual: -> console.log(@); throw "NOT IMPLEMENTED"
    })


    class ExpressionEquality
      initialize: (@first)->
      isEqual: (@second)->
        firstp = ref.refine @first
        firstp.isEqual @second

    class_mixer ExpressionEquality

    ExpressionEquality.isEqual = (a,b)->
      ExpressionEquality.build(a).isEqual(b)

    return ExpressionEquality
