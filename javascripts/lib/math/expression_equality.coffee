#= require lib
#= require lib/math/expression_components
#= require lib/math/expression_equality
#= require almond_wrapper

ttm.define 'lib/math/expression_equality',
  ['lib/class_mixer', 'lib/object_refinement', 'lib/math/expression_components'],
  (class_mixer, object_refinement, comps)->
    ref = object_refinement.build()


    buildIsEqual = (for_type)->
      (other)->
        if other instanceof for_type
          @_simpleIsEqual(other)
        else if other instanceof comps.expression
          ref.refine(other).isEqual @
        else
          false

    ref.forType(comps.expression, {
      isExpressionEqual: (other)->
        if _(@expression).size() == _(@expression).size()
          contains_unequal =
            _.chain(@expression).map((element, i)->
              ref.refine(element).isEqual(other.nth(i))
            ).contains(false).value()
          !contains_unequal
        else
          false

      isNonExpressionEqual: (other)->
        @size() == 1 && ref.refine(@first()).isEqual(other)

      isEqual: (other)->
        if other instanceof comps.expression
          @isExpressionEqual(other)
        else
          @isNonExpressionEqual(other)
    })

    ref.forType(comps.number, {
      isEqual: (buildIsEqual(comps.number)),
      _simpleIsEqual: (other)->
        @value() == other.value()
    })

    ref.forType(comps.addition, {
      isEqual: (buildIsEqual(comps.addition)),
      _simpleIsEqual: (other)-> true # two additions are always equal to one another
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
