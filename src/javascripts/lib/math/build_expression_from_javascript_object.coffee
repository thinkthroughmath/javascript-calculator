
ttm = thinkthroughmath
logger = ttm.logger
class_mixer = ttm.class_mixer

# usage examples found in tests
# conversion process is used
# to figure out which child node has a a cursor
# if any
class ConversionProcess
  initialize: (@processor, @js_object)->
    @position_val = false
  convert: ->
    @converted_val = @processor.convert(@js_object, @)
  converted: ->
    @converted_val
  checkForPosition: (expression_component, js_object)->
    if js_object && js_object.has_cursor
      @position_val = expression_component.id()
  position: ->
    @position_val

class_mixer ConversionProcess

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

    @processor.converters [
      @closed_expression_converter
      @number_converter
      @exponentiation_converter
      @string_literal_converter
      @root_converter
      @variable_converter
      @fraction_converter
      @fn_converter
      ]

  process: (js_object)->
    cp = ConversionProcess.build(@processor, js_object)
    cp.convert()
    cp

  buildExpressionFunction: ->
    =>
      arguments_as_array = Array.prototype.slice.call(arguments, 0)
      conversion_process = @process(arguments_as_array)
      conversion_process.converted()

  buildExpressionPositionFunction: ->
    =>
      arguments_as_array = Array.prototype.slice.call(arguments, 0)
      conversion_process = @process(arguments_as_array)
      if conversion_process.position()
        ttm.lib.math.ExpressionPosition.build(
          expression: conversion_process.converted()
          position: conversion_process.position()
        )
      else
        # default is to use last
        ttm.lib.math.ExpressionPosition.buildExpressionPositionAsLast(
          conversion_process.converted()
        )
class_mixer BuildExpressionFromJavascriptObject

class _JSObjectExpressionProcessor
  converters: (@js_object_converters)->

  convert: (js_object, conversion_process)->
    for converter in @js_object_converters
      if converter.isType(js_object)
        return converter.convert(js_object, conversion_process)
    throw "Unhandled js object: #{JSON.stringify js_object}"
class_mixer _JSObjectExpressionProcessor

class _FromClosedExpressionObject
  initialize: (@expression_builder, @processor)->
  isType: (js_object)->
    typeof js_object == "object" && js_object instanceof Array

  convert: (js_object, conversion_process)->
    exp = @expression_builder.build_expression()
    for part in js_object
      converted_part = @processor.convert(part, conversion_process)
      exp = exp.append(converted_part)
    conversion_process.checkForPosition(exp, js_object)
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

  convert: (js_object, conversion_process)->
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
  convert: (js_object, conversion_process)->

    base_obj = js_object['^'][0]
    power_obj = js_object['^'][1]

    base = convert_implicit_subexp(base_obj, @processor, conversion_process)
    power = convert_implicit_subexp(power_obj, @processor, conversion_process)

    conversion_process.checkForPosition(base, base_obj)
    conversion_process.checkForPosition(power, power_obj)

    @exponentiation_builder.build_exponentiation(
      base: base
      power: power
    )
class_mixer _FromExponentiationObject


class _FromRootObject
  initialize: (@processor, @root_builder)->
  isType: (js_object)-> js_object['root'] instanceof Array
  convert: (js_object, conversion_process)->
    degree = convert_implicit_subexp(js_object['root'][0], @processor, conversion_process)
    radicand = convert_implicit_subexp(js_object['root'][1], @processor, conversion_process)

    @root_builder.build_root(
      degree: degree
      radicand: radicand
    )
class_mixer _FromRootObject

class _FromVariableObject
  initialize: (@processor, @variable_builder)->
  isType: (js_object)-> typeof js_object['variable'] == "string"
  convert: (js_object, conversion_process)->
    @variable_builder.build_variable(name: js_object['variable'])
class_mixer _FromVariableObject

class _FromFractionObject
  initialize: (@processor, @fraction_builder)->
  isType: (js_object)->
    js_object['fraction'] instanceof Array

  convert: (js_object, conversion_process)->
    num_obj = js_object['fraction'][0]
    numerator = convert_implicit_subexp(num_obj, @processor, conversion_process)
    den_obj = js_object['fraction'][1]
    denominator = convert_implicit_subexp(den_obj, @processor, conversion_process)

    conversion_process.checkForPosition(numerator, num_obj)
    conversion_process.checkForPosition(denominator, den_obj)

    @fraction_builder.build_fraction(
      numerator: numerator
      denominator: denominator
    )
class_mixer _FromFractionObject

class _FromFnObject
  initialize: (@converter, @fn_builder)->
  isType: (js_object)->
    js_object['fn'] instanceof Array
  convert: (js_object, conversion_process)->
    name = js_object['fn'][0]
    argument = convert_implicit_subexp(js_object['fn'][1], @converter, conversion_process)

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

  convert: (js_object, conversion_process)->
    @converter[@literal_mappings[js_object]]()

class_mixer _FromStringLiteralObject

convert_implicit_subexp = (subexp, processor, conversion_process)->
    maybe_wrapped =
      if typeof subexp == "number"
        [subexp]
      else if !subexp
        []
      else
        subexp
    processed = processor.convert(maybe_wrapped, conversion_process)


ttm.lib.math.BuildExpressionFromJavascriptObject = BuildExpressionFromJavascriptObject

