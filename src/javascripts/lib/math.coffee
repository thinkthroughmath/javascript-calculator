ttm = thinkthroughmath
ttm.lib.math ||= {}

require './math/precise'
require './math/expression_components'
require './math/expression_equality'
require './math/expression_evaluation'
require './math/expression_manipulation'
require './math/expression_position'
require './math/build_expression_from_javascript_object'
require './math/expression_traversal'
require './math/equation_checking'
require './math/expression_to_string'
require './math/expression_to_mathml_conversion'


class MathLib
  initialize: (opts={})->
    precise = opts.precise || ttm.lib.math.Precise.build()
    comps = opts.comps || ttm.lib.math.ExpressionComponentSource.build(precise)

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

ttm.lib.math.math_lib = ttm.class_mixer MathLib
