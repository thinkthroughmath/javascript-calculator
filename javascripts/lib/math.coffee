#= require almond_wrapper
#= require lib
#= require lib/math/expression_components
#= require lib/math/buttons
#= require lib/math/expression_evaluation
#= require lib/math/expression_manipulation

ttm.define "lib/math",
  [ "lib/class_mixer", 'lib/math/expression_components',
    'lib/math/expression_evaluation',
    'lib/math/expression_manipulation'],
  (class_mixer, comps, expression_evaluation, manipulation)->
    exports =
      equation: comps.equation
      expression: comps.expression
      components: comps
      commands: manipulation
    return exports


