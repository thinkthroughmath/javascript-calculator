#= require almond_wrapper
#= require lib
#= require lib/math/expression_components
#= require lib/math/expression_equality
#= require lib/math/expression_evaluation
#= require lib/math/expression_manipulation
#= require lib/math/build_expression_from_javascript_object
#= require lib/math/precise

class MathLib
  initialize: (opts={})->
    # TODO refactor these removing them
    ttm.require('lib/math/expression_manipulation')
    ttm.require('lib/math/build_expression_from_javascript_object')
    ttm.require('lib/math/expression_evaluation')
    ttm.require('lib/math/expression_equality')
    comps = opts.comps || ttm.lib.math.ExpressionComponentSource.build()

    @components = opts.components || comps
    @equation = opts.equation || comps.equation
    @expression = opts.expression || comps.expression

    @expression_position = opts.expression_position || ttm.lib.math.ExpressionPosition
    @traversal = opts.traversal || ttm.lib.math.ExpressionTraversalBuilder.build(comps.classes)

    @commands = opts.commands || ttm.lib.math.ExpressionManipulationSource.build(comps, @expression_position, @traversal)

    @object_to_expression = opts.object_to_expression || ttm.lib.math.BuildExpressionFromJavascriptObject.build(component_builder: @components)

    @evaluation = opts.evaluation || ttm.lib.math.ExpressionEvaluation

    @expression_equality = opts.expression_equality || ttm.lib.math.ExpressionEquality

    @equation_checking = opts.equation_checking || ttm.lib.math.EquationCheckingBuilder.build(@commands, @traversal, @evaluation, @expression_equality.isEqual)



ttm.class_mixer MathLib

window.ttm.lib.math.math_lib = MathLib
