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
      process: (object_to_convert)->
        if object_to_convert.length != undefined && typeof object_to_convert != "string"
          exp = @expression_builder.build()
          for x in object_to_convert
            exp = exp.append(@process(x))
          exp
        else
          switch typeof(object_to_convert)
            when "number" then @number_builder.build(value: object_to_convert)
            when "string"
              switch object_to_convert
                when "+" then @addition_builder.build()
                when "/" then @division_builder.build()
            when "object" then @convertObject(object_to_convert)

      convertObject: (object)->
        if (it = object['^'])
          @exponentiation_builder.build(base: @process(it[0]), power: @process(it[1]))

    class_mixer BuildExpressionFromJavascriptObject

    builder = ->
      builder = BuildExpressionFromJavascriptObject.build()
      builder.process(arguments)
    return builder
