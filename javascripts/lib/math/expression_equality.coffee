#= require ./base
#= require lib
#= require lib/math/expression_components
#= require lib/math/expression_equality
#= require almond_wrapper

ttm.define 'lib/math/expression_equality',
  ['lib/class_mixer', 'lib/object_refinement'],
  (class_mixer, object_refinement)->
    ref = object_refinement.build()
    comps = ttm.lib.math.ExpressionComponentSource.build()
    buildIsEqual = (for_type, additional_method=false)->
      isEqualFunction = (other, eq_calc)->
        same_type = (other instanceof for_type)
        eq_calc.saveFalseForReport(same_type, @unrefined(), other,
          "different types #{for_type.name}")
        if same_type
          if additional_method
            @[additional_method](other, eq_calc)
          else
            true
        else
          false
      logger.instrument(name: "buildIsEqual function", fn: isEqualFunction)

    # Addition
    ref.forType(comps.classes.addition, {
      isEqual: (buildIsEqual(comps.classes.addition))
      })

    # Blank
    ref.forType(comps.classes.blank, {
      isEqual: (buildIsEqual(comps.classes.blank))
      })

    # Division
    ref.forType(comps.classes.division, {
      isEqual: (buildIsEqual(comps.classes.division))
      })

    # Exponentiation
    ref.forType(comps.classes.exponentiation, {
      isEqual: (buildIsEqual(comps.classes.exponentiation, "checkBaseAndPowerEquality")),
      checkBaseAndPowerEquality: (other, eq_comp)->
        base_equal = ref.refine(@base()).isEqual(other.base(), eq_comp)
        power_equal = ref.refine(@power()).isEqual(other.power(), eq_comp)
        base_equal && power_equal # no need to save, report comes from below
      })

    # Expression
    ref.forType(comps.classes.expression, {
      isExpressionEqual: (other, eq_calc)->
        logger.info("isExpressionEqual", @unrefined(), other)
        match_error = @is_error == other.is_error
        eq_calc.saveFalseForReport(match_error, @unrefined(), other, "error values not equal")

        match_open = @is_open == other.is_open
        eq_calc.saveFalseForReport(match_open, @unrefined(), other, "open values not equal")


        if match_error && match_open
          contains_unequal =
            _.chain(@expression).map((element, i)->
              ret = ref.refine(element).isEqual(other.nth(i), eq_calc)
              ret
            ).contains(false).value()
          if contains_unequal
            false
          else
            match_size = _(@expression).size() == _(other.expression).size()
            eq_calc.saveFalseForReport(match_size, @unrefined(), other, "size values not equal")
        else
          false

      isEqual: (other, eq_calc)->

        same_type = eq_calc.saveFalseForReport((other instanceof comps.classes.expression), @unrefined(), other,
          "Wrong types")
        if same_type
          @isExpressionEqual(other, eq_calc)
        else
          false
    })

    # Equals
    ref.forType(comps.classes.equals, {
      isEqual: (buildIsEqual(comps.classes.equals))
    })


    # Multiplication
    ref.forType(comps.classes.multiplication, {
      isEqual: (buildIsEqual(comps.classes.multiplication))
      })

    # Number
    ref.forType(comps.classes.number, {
      isEqual: (buildIsEqual(comps.classes.number, "checkNumberValues")),
      checkNumberValues: (other, eq_calc)->

        # this is bad; TODO fix
        # The real "todo" here is that
        # numbers are internally of questionable state.
        # Im not entirely sure how to state that number expresison components are equal
        check = "#{@value()}" == "#{other.value()}"
        eq_calc.saveFalseForReport(check, @unrefined(), other, "Numeric values not equal")
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

    # Pi
    ref.forType(comps.classes.pi, {
      isEqual: (buildIsEqual(comps.classes.pi))
    })

    # Subtraction
    ref.forType(comps.classes.subtraction, {
      isEqual: (buildIsEqual(comps.classes.subtraction))
    })

    # Root
    ref.forType(comps.classes.root, {
      isEqual: (buildIsEqual(comps.classes.root, "checkDegreeAndRadicand")),
      checkDegreeAndRadicand: (other, eq_calc)->
        degree_equal = ref.refine(@degree()).isEqual(other.degree(), eq_calc)
        radicand_equal = ref.refine(@radicand()).isEqual(other.radicand(), eq_calc)
        degree_equal and radicand_equal # no need to save, report comes from below
    })


    # Variable
    ref.forType(comps.classes.variable, {
      isEqual: (buildIsEqual(comps.classes.variable, "checkNames")),
      checkNames: (other, eq_calc)->
        check = "#{@name()}" == "#{other.name()}"
        eq_calc.saveFalseForReport(check, @unrefined(), other, "Variable names not equal")
    })


    ref.forDefault({
      isEqual: ->
        throw ["Unimplemented equality refinement for ", @unrefined()]
    })

    class ExpressionEquality
      initialize: ->
        @report_saved = false

      calculate: (@first, @second)->
        firstp = ref.refine @first
        @_equality_results = firstp.isEqual @second, @
        @

      isEqual: ->
        @_equality_results

      notEqualReport: (@a, @b, @not_eql_msg)->
        @report_saved = true

      saveFalseForReport: (value, a, b, msg)->
        if value
          true
        else
          @notEqualReport(a, b, msg) unless @report_saved
          false

    class_mixer ExpressionEquality

    ExpressionEquality.isEqual = (a,b)->
      ExpressionEquality.build().calculate(a,b).isEqual()

    ExpressionEquality.equalityCalculation = (a,b)->
      ec = ExpressionEquality.build()
      ec.calculate(a,b)
      ec

    ttm.lib.math.ExpressionEquality = ExpressionEquality
    return ExpressionEquality
