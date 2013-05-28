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
        @equals_builder = @opts.equals_builder || components.equals
        @pi_builder = @opts.pi_builder || components.pi

        @processor = _JSObjectExpressionProcessor.build()

        @exponentiation_converter = _FromExponentiationObject.build(
          @processor,
          @exponentiation_builder)

        @string_literal_converter = _FromStringLiteralObject.build(
          "+": @addition_builder
          "-": @subtraction_builder
          "/": @division_builder
          "*": @multiplication_builder
          "=": @equals_builder
          "pi": @pi_builder
        )

        @closed_expression_converter = _FromClosedExpressionObject.build(
          @expression_builder,
          @processor)

        @number_converter = _FromNumberObject.build(@number_builder)
        @open_expression_converter = _FromOpenExpressionObject.build(@closed_expression_converter)

        @processor.converters [
          @closed_expression_converter
          @open_expression_converter
          @number_converter
          @exponentiation_converter
          @string_literal_converter
          ]

      process: (js_object)->
        @processor.process(js_object)

      processBuildExpression: (data)->
        @process(data)

    class_mixer BuildExpressionFromJavascriptObject

    class _JSObjectExpressionProcessor
      converters: (@js_object_converters)->

      process: (js_object)->
        for converter in @js_object_converters
          if converter.isType(js_object)
            return converter.convert(js_object)
        throw "Unhandled js object: #{JSON.stringify js_object}"
    class_mixer _JSObjectExpressionProcessor

    class _FromOpenExpressionObject
      initialize: (@expression_converter)->
      isType: (js_object)->
        js_object['open_expression'] != undefined

      convert = (js_object)->
        subexp = js_object['open_expression']
        maybe_wrapped =
          if typeof subexp == "number"
            [subexp]
          else if subexp == null || subexp == false
            []
          else if @isType(subexp) # this open expression contains another open expression
            [subexp]
          else subexp
        @expression_converter.convert(maybe_wrapped).open()

      convert: logger().instrument(name: "_FromOpenExpressionObject#convert", fn: convert)

    class_mixer _FromOpenExpressionObject

    class _FromClosedExpressionObject
      initialize: (@expression_builder, @processor)->
      isType: (js_object)->
        typeof js_object == "object" && js_object instanceof Array

      convert: (js_object)->
        exp = @expression_builder.build()
        for part in js_object
          converted_part = @processor.process(part)
          exp = exp.append(converted_part)
        exp
    class_mixer _FromClosedExpressionObject

    class _FromNumberObject
      initialize: (@number_builder)->

      isType: (js_object)->
        @isJSNumber(js_object) or @isStringNumber(js_object)

      isJSNumber: (js_object)->
        typeof js_object == "number"

      isStringNumber: (js_object)->
        typeof js_object == "string" and js_object.search(/\d+/) != -1

      convert: (js_object)->
        if @isJSNumber(js_object)
          @number_builder.build(value: js_object)
        else if @isStringNumber(js_object)
          @numberFromString(js_object)

      numberFromString: (str)->
        if parsed = str.match /(\d+)(\.)(\d+)/
          @number_builder.build(value: str)
        else if parsed = str.match /(\d+)(\.)/
          @number_builder.build(value: parsed[1], future_as_decimal: true)
        else if parsed = str.match /(\d+)/
          @number_builder.build(value: parsed[1])

    class_mixer _FromNumberObject

    class _FromExponentiationObject
      initialize: (@processor, @exponentiation_builder)->
      isType: (js_object)-> js_object['^'] instanceof Array
      convert: (js_object)->
        base = @convertImplicitSubexp(js_object['^'][0])
        power = @convertImplicitSubexp(js_object['^'][1])

        @exponentiation_builder.build(
          base: base
          power: power
        )

      convertImplicitSubexp: (subexp)->
        maybe_wrapped =
          if typeof subexp == "number"
            [subexp]
          else if subexp == null || subexp == false
            []
          else
            subexp
        processed = @processor.process(maybe_wrapped)
    class_mixer _FromExponentiationObject

    class _FromStringLiteralObject
      initialize: (@literal_mappings)->
        @keys = _.keys(@literal_mappings)

      isType: (js_object)->
        @keys.indexOf(js_object) != -1

      convert: (js_object)->
        @literal_mappings[js_object].build()

    class_mixer _FromStringLiteralObject

    BuildExpressionFromJavascriptObject.buildExpression = ->
      builder = BuildExpressionFromJavascriptObject.build()
      arguments_as_array = Array.prototype.slice.call(arguments, 0)
      converted_part = builder.processBuildExpression(arguments_as_array)
      logger().info("returned converted from process in buildExpression", converted_part.toString(), arguments_as_array)
      converted_part

    return BuildExpressionFromJavascriptObject

