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
        @subtraction_builder = @opts.subtraction_builder || components.subtraction
        @division_builder = @opts.division_builder || components.division
        @exponentiation_builder = @opts.exponentiation_builder || components.exponentiation
        @blank_builder = @opts.blank_builder || components.blank
        @multiplication_builder = @opts.multiplication_builder || components.multiplication


      proc_method = (object_to_convert)->
        return @blank_builder.build() unless object_to_convert
        if object_to_convert instanceof Array
          @convertSubExpression(object_to_convert)
        else
          switch typeof(object_to_convert)
            when "number" then @number_builder.build(value: object_to_convert)
            when "string"
              obj = object_to_convert
              switch
                when obj == "+" then @addition_builder.build()
                when obj == "-" then @subtraction_builder.build()
                when obj == "/" then @division_builder.build()
                when obj == "*" then @multiplication_builder.build()
                when @matchesNumberRegexp(obj)
                  @numberFromString(obj)
                else throw "STRING NOT IMPLEMENTED"
            when "object" then @convertObject(object_to_convert)
      process: logger().instrument(name: "Process", fn: proc_method)


      matchesNumberRegexp: (str)->
        str.search(/\d+/) != -1

      numberFromString: (str)->
        if parsed = str.match /(\d+)(\.)(\d+)/
          @number_builder.build(value: str)
        else if parsed = str.match /(\d+)(\.)/
          @number_builder.build(value: parsed[1], future_as_decimal: true)
        else if parsed = str.match /(\d+)/
          @number_builder.build(value: parsed[1])

      # privates
      convertSubExpression: (parts) ->
        exp = @expression_builder.build()
        for x in parts
          converted_part = @process(x)
          exp = exp.append(converted_part)
        exp

      convertObject: (object)->
        if (it = object['^'])
          @convertExponentiation(it)
        else if ((it = object['open_expression']) != undefined)
          subexp = @convertImplicitSubexp(it)
          subexp.open()
        else
          throw "Build Exp not recognized"

      convertExponentiation: (data)->
        base = @convertImplicitSubexp(data[0])
        power = @convertImplicitSubexp(data[1])

        @exponentiation_builder.build(
          base: base
          power: power
        )

      convertImplicitSubexp = (subexp)->
        processed = @process(subexp)
        if typeof subexp == "number"
          @expression_builder.build(expression: [processed])
        else if subexp == null || subexp == false
          @expression_builder.build(expression: [])
        else if subexp instanceof Array
          processed
        else
          @expression_builder.build(expression: [processed])

      convertImplicitSubexp: logger().instrument(name: "convertImplicitSubexp", fn: convertImplicitSubexp)

    class_mixer BuildExpressionFromJavascriptObject

    BuildExpressionFromJavascriptObject.buildExpression = ->
      builder = BuildExpressionFromJavascriptObject.build()
      arguments_as_array = Array.prototype.slice.call(arguments, 0)
      converted_part = builder.process(arguments_as_array)
      logger().info("returned converted from process in buildExpression", converted_part.toString(), arguments_as_array)
      converted_part

    return BuildExpressionFromJavascriptObject

