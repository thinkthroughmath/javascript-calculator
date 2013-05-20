#= require lib/math
#= require lib/math/expression_components



# usage examples found in tests
ttm.define 'lib/math/build_expression_from_javascript_object',
  ['lib/class_mixer', 'lib/math/expression_components'],
  (class_mixer, components)->
    class BuildExpressionFromJavascriptObject
      initialize: (@opts={})->
        @expression_builder = @opts.expression_builder || components.expression
        @number_builder = @opts.number_builder || components.number
        @addition_builder = @opts.addition_builder || components.addition
        @division_builder = @opts.division_builder || components.division
        @exponentiation_builder = @opts.exponentiation_builder || components.exponentiation
        @blank_builder = @opts.blank_builder || components.blank
        @multiplication_builder = @opts.multiplication_builder || components.multiplication

      process: (object_to_convert)->
        return @blank_builder.build() unless object_to_convert
        if object_to_convert instanceof Array
          exp = @expression_builder.build()
          @processExpressionParts(exp, object_to_convert)
        else
          switch typeof(object_to_convert)
            when "number" then @number_builder.build(value: object_to_convert)
            when "string"
              switch object_to_convert
                when "+" then @addition_builder.build()
                when "/" then @division_builder.build()
                when "*" then @multiplication_builder.build()
            when "object" then @convertObject(object_to_convert)

      # privates
      processExpressionParts: (exp, parts)->
        throw "Expression parts must be an instance of array" unless parts instanceof Array
        for x in parts
          exp = exp.append(@process(x))
        exp

      convertObject: (object)->
        if (it = object['^'])
          @exponentiation_builder.build(base: @process(it[0]), power: @process(it[1]))
        else if (it = object['open_expression'])
          processed_exp = @process(it)
          if it instanceof Array
            val = processed_exp.open()
          else
            val = @expression_builder.build(expression: [processed_exp], is_open: true)
          val
        else
          throw "Build Exp not recognized"

    class_mixer BuildExpressionFromJavascriptObject


    BuildExpressionFromJavascriptObject.buildExpression = ->
      builder = BuildExpressionFromJavascriptObject.build()
      arguments_as_array = Array.prototype.slice.call(arguments, 0)
      builder.process(arguments_as_array)

    return BuildExpressionFromJavascriptObject
