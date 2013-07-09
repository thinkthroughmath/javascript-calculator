# usage examples found in tests
ttm.define 'lib/math/build_expression_from_javascript_object',
  ['lib/class_mixer'],
  (class_mixer)->
    class BuildExpressionFromJavascriptObject
      initialize: (@opts={})->
        @component_builder = @opts.component_builder
        unless @component_builder
          throw "BuildExpressionFromJavascriptObject requires component builder option"
        @processor = _JSObjectExpressionProcessor.build()

        @root_converter = _FromRootObject.build(
          @processor,
          @component_builder)

        @number_converter = _FromNumberObject.build(@component_builder)

        @exponentiation_converter = _FromExponentiationObject.build(
          @processor,
          @component_builder)

        @fraction_converter = _FromFractionObject.build(
          @processor,
          @component_builder)

        @fn_converter = _FromFnObject.build(
          @processor,
          @component_builder
        )


        @string_literal_converter = _FromStringLiteralObject.build(@component_builder,{
          "+": "build_addition"
          "-": "build_subtraction"
          "/": "build_division"
          "*": "build_multiplication"
          "=": "build_equals"
          "pi": "build_pi"
        })

        @closed_expression_converter = _FromClosedExpressionObject.build(
          @component_builder,
          @processor)

        @variable_converter = _FromVariableObject.build(
          @processor,
          @component_builder)

        @open_expression_converter = _FromOpenExpressionObject.build(@closed_expression_converter)

        @processor.converters [
          @closed_expression_converter
          @open_expression_converter
          @number_converter
          @exponentiation_converter
          @string_literal_converter
          @root_converter
          @variable_converter
          @fraction_converter
          @fn_converter
          ]

      process: (js_object)->
        @processor.process(js_object)

      processBuildExpression: (data)->
        @process(data)

      buildExpressionFunction: ->
        @builderFunction()
      buildExpressionPositionFunction: ->
        @builderFunctionExpressionWithPositionAsLast()

      builderFunction: ->
        =>
          arguments_as_array = Array.prototype.slice.call(arguments, 0)
          converted_part = @processBuildExpression(arguments_as_array)
          converted_part

      builderFunctionExpressionWithPositionAsLast: ->
        =>
          arguments_as_array = Array.prototype.slice.call(arguments, 0)
          expression = @processBuildExpression(arguments_as_array)
          ttm.lib.math.ExpressionPosition.buildExpressionPositionAsLast(expression)

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

      convert: logger.instrument(name: "_FromOpenExpressionObject#convert", fn: convert)

    class_mixer _FromOpenExpressionObject

    class _FromClosedExpressionObject
      initialize: (@expression_builder, @processor)->
      isType: (js_object)->
        typeof js_object == "object" && js_object instanceof Array

      convert: (js_object)->
        exp = @expression_builder.build_expression()
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
          @number_builder.build_number(value: js_object)
        else if @isStringNumber(js_object)
          @numberFromString(js_object)

      numberFromString: (str)->
        if parsed = str.match /(\d+)(\.)(\d+)/
          @number_builder.build_number(value: str)
        else if parsed = str.match /(\d+)(\.)/
          @number_builder.build_number(value: parsed[1], future_as_decimal: true)
        else if parsed = str.match /(\d+)/
          @number_builder.build_number(value: parsed[1])

    class_mixer _FromNumberObject

    class _FromExponentiationObject
      initialize: (@processor, @exponentiation_builder)->
      isType: (js_object)-> js_object['^'] instanceof Array
      convert: (js_object)->
        base = convert_implicit_subexp(js_object['^'][0], @processor)
        power = convert_implicit_subexp(js_object['^'][1], @processor)

        @exponentiation_builder.build_exponentiation(
          base: base
          power: power
        )
    class_mixer _FromExponentiationObject


    class _FromRootObject
      initialize: (@processor, @root_builder)->
      isType: (js_object)-> js_object['root'] instanceof Array
      convert: (js_object)->
        degree = convert_implicit_subexp(js_object['root'][0], @processor)
        radicand = convert_implicit_subexp(js_object['root'][1], @processor)

        @root_builder.build_root(
          degree: degree
          radicand: radicand
        )
    class_mixer _FromRootObject

    class _FromVariableObject
      initialize: (@processor, @variable_builder)->
      isType: (js_object)-> typeof js_object['variable'] == "string"
      convert: (js_object)->
        @variable_builder.build_variable(name: js_object['variable'])
    class_mixer _FromVariableObject

    class _FromFractionObject
      initialize: (@processor, @fraction_builder)->
      isType: (js_object)->
        js_object['fraction'] instanceof Array

      convert: (js_object)->
        numerator = convert_implicit_subexp(js_object['fraction'][0], @processor)
        denominator = convert_implicit_subexp(js_object['fraction'][1], @processor)

        @fraction_builder.build_fraction(
          numerator: numerator
          denominator: denominator
        )
    class_mixer _FromFractionObject

    class _FromFnObject
      initialize: (@converter, @fn_builder)->
      isType: (js_object)->
        js_object['fn'] instanceof Array
      convert: (js_object)->
        name = js_object['fn'][0]
        argument = convert_implicit_subexp(js_object['fn'][1], @converter)

        @fn_builder.build_fn(
          name: name
          argument: argument
        )
    class_mixer _FromFnObject

    class _FromStringLiteralObject
      initialize: (@converter, @literal_mappings)->
        @keys = _.keys(@literal_mappings)

      isType: (js_object)->
        @keys.indexOf(js_object) != -1

      convert: (js_object)->
        @converter[@literal_mappings[js_object]]()

    class_mixer _FromStringLiteralObject

    convert_implicit_subexp = (subexp, processor)->
        maybe_wrapped =
          if typeof subexp == "number"
            [subexp]
          else if subexp == null || subexp == false
            []
          else
            subexp
        processed = processor.process(maybe_wrapped)

    # export for now
    ttm.lib.math.BuildExpressionFromJavascriptObject = BuildExpressionFromJavascriptObject

    return BuildExpressionFromJavascriptObject

