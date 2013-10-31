;(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};(function() {
  var root, _base;

  root = window || global;

  root.thinkthroughmath || (root.thinkthroughmath = {});

  (_base = root.thinkthroughmath).lib || (_base.lib = {});

  require("./math");

}).call(this);

},{"./math":2}],2:[function(require,module,exports){
(function() {
  var MathLib, ttm, _base;

  ttm = thinkthroughmath;

  (_base = ttm.lib).math || (_base.math = {});

  require('./math/precise');

  require('./math/expression_components');

  require('./math/expression_equality');

  require('./math/expression_evaluation');

  require('./math/expression_manipulation');

  require('./math/expression_position');

  require('./math/build_expression_from_javascript_object');

  require('./math/expression_traversal');

  require('./math/expression_to_string');

  MathLib = (function() {
    function MathLib() {}

    MathLib.prototype.initialize = function(opts) {
      var comps, precise;
      if (opts == null) {
        opts = {};
      }
      precise = opts.precise || ttm.lib.math.Precise.build();
      comps = opts.comps || ttm.lib.math.ExpressionComponentSource.build(precise);
      this.components = opts.components || comps;
      this.equation = opts.equation || comps.equation;
      this.expression = opts.expression || comps.expression;
      this.expression_position = opts.expression_position || ttm.lib.math.ExpressionPosition;
      this.traversal = opts.traversal || ttm.lib.math.ExpressionTraversalBuilder.build(comps.classes);
      this.commands = opts.commands || ttm.lib.math.ExpressionManipulationSource.build(comps, this.expression_position, this.traversal);
      this.object_to_expression = opts.object_to_expression || ttm.lib.math.BuildExpressionFromJavascriptObject.build({
        component_builder: this.components
      });
      this.evaluation = opts.evaluation || ttm.lib.math.ExpressionEvaluation;
      return this.expression_equality = opts.expression_equality || ttm.lib.math.ExpressionEquality;
    };

    return MathLib;

  })();

  ttm.lib.math.math_lib = ttm.class_mixer(MathLib);

}).call(this);

},{"./math/build_expression_from_javascript_object":3,"./math/expression_components":4,"./math/expression_equality":5,"./math/expression_evaluation":6,"./math/expression_manipulation":7,"./math/expression_position":8,"./math/expression_to_string":9,"./math/expression_traversal":10,"./math/precise":11}],3:[function(require,module,exports){
(function() {
  var BuildExpressionFromJavascriptObject, ConversionProcess, class_mixer, convert_implicit_subexp, logger, ttm, _FromClosedExpressionObject, _FromExponentiationObject, _FromFnObject, _FromFractionObject, _FromNumberObject, _FromRootObject, _FromStringLiteralObject, _FromVariableObject, _JSObjectExpressionProcessor;

  ttm = thinkthroughmath;

  logger = ttm.logger;

  class_mixer = ttm.class_mixer;

  ConversionProcess = (function() {
    function ConversionProcess() {}

    ConversionProcess.prototype.initialize = function(processor, js_object) {
      this.processor = processor;
      this.js_object = js_object;
      return this.position_val = false;
    };

    ConversionProcess.prototype.convert = function() {
      return this.converted_val = this.processor.convert(this.js_object, this);
    };

    ConversionProcess.prototype.converted = function() {
      return this.converted_val;
    };

    ConversionProcess.prototype.checkForPosition = function(expression_component, js_object) {
      if (js_object && js_object.has_cursor) {
        return this.position_val = expression_component.id();
      }
    };

    ConversionProcess.prototype.position = function() {
      return this.position_val;
    };

    return ConversionProcess;

  })();

  class_mixer(ConversionProcess);

  BuildExpressionFromJavascriptObject = (function() {
    function BuildExpressionFromJavascriptObject() {}

    BuildExpressionFromJavascriptObject.prototype.initialize = function(opts) {
      this.opts = opts != null ? opts : {};
      this.component_builder = this.opts.component_builder;
      if (!this.component_builder) {
        throw "BuildExpressionFromJavascriptObject requires component builder option";
      }
      this.processor = _JSObjectExpressionProcessor.build();
      this.root_converter = _FromRootObject.build(this.processor, this.component_builder);
      this.number_converter = _FromNumberObject.build(this.component_builder);
      this.exponentiation_converter = _FromExponentiationObject.build(this.processor, this.component_builder);
      this.fraction_converter = _FromFractionObject.build(this.processor, this.component_builder);
      this.fn_converter = _FromFnObject.build(this.processor, this.component_builder);
      this.string_literal_converter = _FromStringLiteralObject.build(this.component_builder, {
        "+": "build_addition",
        "-": "build_subtraction",
        "/": "build_division",
        "*": "build_multiplication",
        "=": "build_equals",
        "pi": "build_pi"
      });
      this.closed_expression_converter = _FromClosedExpressionObject.build(this.component_builder, this.processor);
      this.variable_converter = _FromVariableObject.build(this.processor, this.component_builder);
      return this.processor.converters([this.closed_expression_converter, this.number_converter, this.exponentiation_converter, this.string_literal_converter, this.root_converter, this.variable_converter, this.fraction_converter, this.fn_converter]);
    };

    BuildExpressionFromJavascriptObject.prototype.process = function(js_object) {
      var cp;
      cp = ConversionProcess.build(this.processor, js_object);
      cp.convert();
      return cp;
    };

    BuildExpressionFromJavascriptObject.prototype.buildExpressionFunction = function() {
      var _this = this;
      return function() {
        var arguments_as_array, conversion_process;
        arguments_as_array = Array.prototype.slice.call(arguments, 0);
        conversion_process = _this.process(arguments_as_array);
        return conversion_process.converted();
      };
    };

    BuildExpressionFromJavascriptObject.prototype.buildExpressionPositionFunction = function() {
      var _this = this;
      return function() {
        var arguments_as_array, conversion_process;
        arguments_as_array = Array.prototype.slice.call(arguments, 0);
        conversion_process = _this.process(arguments_as_array);
        if (conversion_process.position()) {
          return ttm.lib.math.ExpressionPosition.build({
            expression: conversion_process.converted(),
            position: conversion_process.position()
          });
        } else {
          return ttm.lib.math.ExpressionPosition.buildExpressionPositionAsLast(conversion_process.converted());
        }
      };
    };

    return BuildExpressionFromJavascriptObject;

  })();

  class_mixer(BuildExpressionFromJavascriptObject);

  _JSObjectExpressionProcessor = (function() {
    function _JSObjectExpressionProcessor() {}

    _JSObjectExpressionProcessor.prototype.converters = function(js_object_converters) {
      this.js_object_converters = js_object_converters;
    };

    _JSObjectExpressionProcessor.prototype.convert = function(js_object, conversion_process) {
      var converter, _i, _len, _ref;
      _ref = this.js_object_converters;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        converter = _ref[_i];
        if (converter.isType(js_object)) {
          return converter.convert(js_object, conversion_process);
        }
      }
      throw "Unhandled js object: " + (JSON.stringify(js_object));
    };

    return _JSObjectExpressionProcessor;

  })();

  class_mixer(_JSObjectExpressionProcessor);

  _FromClosedExpressionObject = (function() {
    function _FromClosedExpressionObject() {}

    _FromClosedExpressionObject.prototype.initialize = function(expression_builder, processor) {
      this.expression_builder = expression_builder;
      this.processor = processor;
    };

    _FromClosedExpressionObject.prototype.isType = function(js_object) {
      return typeof js_object === "object" && js_object instanceof Array;
    };

    _FromClosedExpressionObject.prototype.convert = function(js_object, conversion_process) {
      var converted_part, exp, part, _i, _len;
      exp = this.expression_builder.build_expression();
      for (_i = 0, _len = js_object.length; _i < _len; _i++) {
        part = js_object[_i];
        converted_part = this.processor.convert(part, conversion_process);
        exp = exp.append(converted_part);
      }
      conversion_process.checkForPosition(exp, js_object);
      return exp;
    };

    return _FromClosedExpressionObject;

  })();

  class_mixer(_FromClosedExpressionObject);

  _FromNumberObject = (function() {
    function _FromNumberObject() {}

    _FromNumberObject.prototype.initialize = function(number_builder) {
      this.number_builder = number_builder;
    };

    _FromNumberObject.prototype.isType = function(js_object) {
      return this.isJSNumber(js_object) || this.isStringNumber(js_object);
    };

    _FromNumberObject.prototype.isJSNumber = function(js_object) {
      return typeof js_object === "number";
    };

    _FromNumberObject.prototype.isStringNumber = function(js_object) {
      return typeof js_object === "string" && js_object.search(/\d+/) !== -1;
    };

    _FromNumberObject.prototype.convert = function(js_object, conversion_process) {
      if (this.isJSNumber(js_object)) {
        return this.number_builder.build_number({
          value: js_object
        });
      } else if (this.isStringNumber(js_object)) {
        return this.numberFromString(js_object);
      }
    };

    _FromNumberObject.prototype.numberFromString = function(str) {
      var parsed;
      if (parsed = str.match(/(\d+)(\.)(\d+)/)) {
        return this.number_builder.build_number({
          value: str
        });
      } else if (parsed = str.match(/(\d+)(\.)/)) {
        return this.number_builder.build_number({
          value: parsed[1],
          future_as_decimal: true
        });
      } else if (parsed = str.match(/(\d+)/)) {
        return this.number_builder.build_number({
          value: parsed[1]
        });
      }
    };

    return _FromNumberObject;

  })();

  class_mixer(_FromNumberObject);

  _FromExponentiationObject = (function() {
    function _FromExponentiationObject() {}

    _FromExponentiationObject.prototype.initialize = function(processor, exponentiation_builder) {
      this.processor = processor;
      this.exponentiation_builder = exponentiation_builder;
    };

    _FromExponentiationObject.prototype.isType = function(js_object) {
      return js_object['^'] instanceof Array;
    };

    _FromExponentiationObject.prototype.convert = function(js_object, conversion_process) {
      var base, base_obj, power, power_obj;
      base_obj = js_object['^'][0];
      power_obj = js_object['^'][1];
      base = convert_implicit_subexp(base_obj, this.processor, conversion_process);
      power = convert_implicit_subexp(power_obj, this.processor, conversion_process);
      conversion_process.checkForPosition(base, base_obj);
      conversion_process.checkForPosition(power, power_obj);
      return this.exponentiation_builder.build_exponentiation({
        base: base,
        power: power
      });
    };

    return _FromExponentiationObject;

  })();

  class_mixer(_FromExponentiationObject);

  _FromRootObject = (function() {
    function _FromRootObject() {}

    _FromRootObject.prototype.initialize = function(processor, root_builder) {
      this.processor = processor;
      this.root_builder = root_builder;
    };

    _FromRootObject.prototype.isType = function(js_object) {
      return js_object['root'] instanceof Array;
    };

    _FromRootObject.prototype.convert = function(js_object, conversion_process) {
      var degree, radicand;
      degree = convert_implicit_subexp(js_object['root'][0], this.processor, conversion_process);
      radicand = convert_implicit_subexp(js_object['root'][1], this.processor, conversion_process);
      return this.root_builder.build_root({
        degree: degree,
        radicand: radicand
      });
    };

    return _FromRootObject;

  })();

  class_mixer(_FromRootObject);

  _FromVariableObject = (function() {
    function _FromVariableObject() {}

    _FromVariableObject.prototype.initialize = function(processor, variable_builder) {
      this.processor = processor;
      this.variable_builder = variable_builder;
    };

    _FromVariableObject.prototype.isType = function(js_object) {
      return typeof js_object['variable'] === "string";
    };

    _FromVariableObject.prototype.convert = function(js_object, conversion_process) {
      return this.variable_builder.build_variable({
        name: js_object['variable']
      });
    };

    return _FromVariableObject;

  })();

  class_mixer(_FromVariableObject);

  _FromFractionObject = (function() {
    function _FromFractionObject() {}

    _FromFractionObject.prototype.initialize = function(processor, fraction_builder) {
      this.processor = processor;
      this.fraction_builder = fraction_builder;
    };

    _FromFractionObject.prototype.isType = function(js_object) {
      return js_object['fraction'] instanceof Array;
    };

    _FromFractionObject.prototype.convert = function(js_object, conversion_process) {
      var den_obj, denominator, num_obj, numerator;
      num_obj = js_object['fraction'][0];
      numerator = convert_implicit_subexp(num_obj, this.processor, conversion_process);
      den_obj = js_object['fraction'][1];
      denominator = convert_implicit_subexp(den_obj, this.processor, conversion_process);
      conversion_process.checkForPosition(numerator, num_obj);
      conversion_process.checkForPosition(denominator, den_obj);
      return this.fraction_builder.build_fraction({
        numerator: numerator,
        denominator: denominator
      });
    };

    return _FromFractionObject;

  })();

  class_mixer(_FromFractionObject);

  _FromFnObject = (function() {
    function _FromFnObject() {}

    _FromFnObject.prototype.initialize = function(converter, fn_builder) {
      this.converter = converter;
      this.fn_builder = fn_builder;
    };

    _FromFnObject.prototype.isType = function(js_object) {
      return js_object['fn'] instanceof Array;
    };

    _FromFnObject.prototype.convert = function(js_object, conversion_process) {
      var argument, name;
      name = js_object['fn'][0];
      argument = convert_implicit_subexp(js_object['fn'][1], this.converter, conversion_process);
      return this.fn_builder.build_fn({
        name: name,
        argument: argument
      });
    };

    return _FromFnObject;

  })();

  class_mixer(_FromFnObject);

  _FromStringLiteralObject = (function() {
    function _FromStringLiteralObject() {}

    _FromStringLiteralObject.prototype.initialize = function(converter, literal_mappings) {
      this.converter = converter;
      this.literal_mappings = literal_mappings;
      return this.keys = _.keys(this.literal_mappings);
    };

    _FromStringLiteralObject.prototype.isType = function(js_object) {
      return this.keys.indexOf(js_object) !== -1;
    };

    _FromStringLiteralObject.prototype.convert = function(js_object, conversion_process) {
      return this.converter[this.literal_mappings[js_object]]();
    };

    return _FromStringLiteralObject;

  })();

  class_mixer(_FromStringLiteralObject);

  convert_implicit_subexp = function(subexp, processor, conversion_process) {
    var maybe_wrapped, processed;
    maybe_wrapped = typeof subexp === "number" ? [subexp] : !subexp ? [] : subexp;
    return processed = processor.convert(maybe_wrapped, conversion_process);
  };

  ttm.lib.math.BuildExpressionFromJavascriptObject = BuildExpressionFromJavascriptObject;

}).call(this);

},{}],4:[function(require,module,exports){
(function() {
  var Addition, Blank, Division, Equals, Exponentiation, Expression, ExpressionComponent, ExpressionComponentSource, ExpressionIDSource, Fn, Fraction, Multiplication, Number, Pi, Root, Subtraction, Variable, build_klass, components, klass, name, ttm, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ttm = thinkthroughmath;

  ExpressionComponent = (function() {
    function ExpressionComponent() {
      this.cloneData = __bind(this.cloneData, this);
    }

    ExpressionComponent.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.component_source = opts.component_source;
      this.id_value = opts.id;
      return this.parent_value = opts.parent;
    };

    ExpressionComponent.prototype.isNumber = function() {
      return false;
    };

    ExpressionComponent.prototype.isExpression = function() {
      return false;
    };

    ExpressionComponent.prototype.isMultiplication = function() {
      return false;
    };

    ExpressionComponent.prototype.isFraction = function() {
      return false;
    };

    ExpressionComponent.prototype.isVariable = function() {
      return false;
    };

    ExpressionComponent.prototype.isExponentiation = function() {
      return false;
    };

    ExpressionComponent.prototype.isRoot = function() {
      return false;
    };

    ExpressionComponent.prototype.preceedingSubexpression = function() {
      return false;
    };

    ExpressionComponent.prototype.cloneData = function(opts) {
      return ttm.defaults(opts, {
        id: this.id_value,
        parent: this.parent_value
      });
    };

    ExpressionComponent.prototype.clone = function(opts) {
      if (opts == null) {
        opts = {};
      }
      return this.klass.build(this.cloneData(opts));
    };

    ExpressionComponent.prototype.id = function() {
      return this.id_value;
    };

    ExpressionComponent.prototype.subExpressions = function() {
      return [];
    };

    ExpressionComponent.prototype.parent = function() {
      return this.parent_value;
    };

    ExpressionComponent.prototype.withParent = function(parent) {
      var ret;
      return ret = this.clone({
        parent: parent
      });
    };

    ExpressionComponent.prototype.replaceImmediateSubComponentD = function(field, old_comp, new_comp) {
      var comp, index, _i, _len, _ref;
      _ref = this[field];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        comp = _ref[index];
        if (comp.id() === old_comp.id()) {
          new_comp = new_comp.withParent(this);
          this[field][index] = new_comp;
        }
      }
      return null;
    };

    return ExpressionComponent;

  })();

  Equals = (function(_super) {
    __extends(Equals, _super);

    function Equals() {
      _ref = Equals.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Equals.prototype.toString = function() {
      return "=";
    };

    return Equals;

  })(ExpressionComponent);

  ttm.class_mixer(Equals);

  Expression = (function(_super) {
    __extends(Expression, _super);

    function Expression() {
      _ref1 = Expression.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Expression.buildWithContent = function(content) {
      return this.build({
        expression: content
      });
    };

    Expression.buildError = function(content) {
      return this.build({
        is_error: true
      });
    };

    Expression.buildUnlessExpression = function(content) {
      if (content instanceof this.comps.classes.expression) {
        return content;
      } else {
        return this.buildWithContent([content]);
      }
    };

    Expression.prototype.initialize = function(opts) {
      var defaults, part, _i, _len, _ref2;
      if (opts == null) {
        opts = {};
      }
      Expression.__super__.initialize.apply(this, arguments);
      defaults = {
        expression: [],
        is_error: false
      };
      opts = _.extend({}, defaults, opts);
      this.expression = [];
      _ref2 = opts.expression;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        part = _ref2[_i];
        this.expression.push(part.withParent(this));
      }
      return this.is_error = opts.is_error;
    };

    Expression.prototype.cloneData = function(new_vals) {
      if (new_vals == null) {
        new_vals = {};
      }
      return ttm.defaults(Expression.__super__.cloneData.apply(this, arguments), {
        expression: _.map(this.expression, function(it) {
          return it.clone();
        }),
        is_error: this.is_error,
        id: this.id_value
      });
    };

    Expression.prototype.last = function(from_end) {
      if (from_end == null) {
        from_end = 0;
      }
      return this.expression[this.expression.length - 1 - from_end];
    };

    Expression.prototype.first = function() {
      return _.first(this.expression);
    };

    Expression.prototype.nth = function(n) {
      return this.expression[n];
    };

    Expression.prototype.reset = function() {
      return this.expression = [];
    };

    Expression.prototype.size = function() {
      return _(this.expression).size();
    };

    Expression.prototype.isBlank = function() {
      return this.size() === 0;
    };

    Expression.prototype.isEmpty = function() {
      return this.isBlank();
    };

    Expression.prototype.set = function(expression) {
      return this.expression = expression;
    };

    Expression.prototype.append = function(new_last) {
      var expr;
      expr = _.clone(this.expression);
      expr.push(new_last.withParent(this));
      return this.clone({
        expression: expr
      });
    };

    Expression.prototype.appendD = function(new_last) {
      return this.expression.push(new_last.withParent(this));
    };

    Expression.prototype.replaceD = function(old_comp, new_comp) {
      return this.replaceImmediateSubComponentD("expression", old_comp, new_comp);
    };

    Expression.prototype.replaceLast = function(new_last) {
      return this.withoutLast().append(new_last.withParent(this));
    };

    Expression.prototype.replaceLastD = function(new_last) {
      return this.expression[this.expression.length - 1] = new_last.withParent(this);
    };

    Expression.prototype.withoutLast = function() {
      var expr;
      expr = _.clone(this.expression);
      expr = expr.slice(0, expr.length - 1);
      return this.clone({
        expression: expr
      });
    };

    Expression.prototype.withoutLastD = function() {
      return this.expression.splice(this.expression.length - 1, 1);
    };

    Expression.prototype.isError = function() {
      return this.is_error;
    };

    Expression.prototype.isExpression = function() {
      return true;
    };

    Expression.prototype.toString = function() {
      var subexpressions, tf;
      tf = function(it) {
        return it != null ? it : {
          "t": "f"
        };
      };
      subexpressions = _(this.expression).chain().map(function(it) {
        return it.toString();
      }).join(", ").value();
      return "Expression(e: " + (tf(this.is_error)) + ", exp: [" + subexpressions + "])";
    };

    Expression.prototype.subExpressions = function() {
      return this.expression;
    };

    return Expression;

  })(ExpressionComponent);

  ttm.class_mixer(Expression);

  Number = (function(_super) {
    __extends(Number, _super);

    function Number() {
      _ref2 = Number.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Number.prototype.initialize = function(opts) {
      Number.__super__.initialize.apply(this, arguments);
      this.precise = opts.precise_lib;
      this.val = this.normalizeValue(opts.value);
      return this.future_as_decimal = opts.future_as_decimal;
    };

    Number.prototype.toString = function() {
      return "#" + this.val;
    };

    Number.prototype.isNumber = function() {
      return true;
    };

    Number.prototype.negated = function() {
      var value;
      value = this.val * -1;
      return Number.build({
        value: value
      });
    };

    Number.prototype.negatedD = function() {
      return this.val *= -1;
    };

    Number.prototype.toCalculable = function() {
      return parseFloat(this.val);
    };

    Number.prototype.cloneData = function(opts) {
      if (opts == null) {
        opts = {};
      }
      return ttm.defaults(Number.__super__.cloneData.apply(this, arguments), {
        value: this.val,
        future_as_decimal: this.future_as_decimal
      });
    };

    Number.prototype.toDisplay = function() {
      if (this.hasDecimal()) {
        return this.valueAtPrecision();
      } else {
        if (this.future_as_decimal) {
          return "" + this.val + ".";
        } else {
          return "" + this.val;
        }
      }
    };

    Number.prototype.valueAtPrecision = function() {
      var number_decimal_places, parts;
      number_decimal_places = 4;
      parts = ("" + this.val).split(".");
      if (parts[1].length > number_decimal_places) {
        return "" + ((this.val * 1).toFixed(number_decimal_places) * 1);
      } else {
        return "" + this.val;
      }
    };

    Number.prototype.value = function() {
      return this.val;
    };

    Number.prototype.concatenate = function(number) {
      var new_val;
      new_val = this.future_as_decimal ? "" + this.val + "." + number : "" + this.val + number;
      return Number.build({
        value: new_val
      });
    };

    Number.prototype.concatenateD = function(number) {
      if (this.future_as_decimal) {
        this.val = "" + this.val + "." + number;
      } else {
        this.val = "" + this.val + number;
      }
      return this.future_as_decimal = false;
    };

    Number.prototype.futureAsDecimal = function() {
      var future_as_decimal;
      future_as_decimal = !this.hasDecimal();
      return this.clone({
        future_as_decimal: future_as_decimal
      });
    };

    Number.prototype.futureAsDecimalD = function(value) {
      return this.future_as_decimal = value;
    };

    Number.prototype.hasDecimal = function() {
      return /\./.test(this.val);
    };

    Number.prototype.normalizeValue = function(val) {
      var denom, num, _ref3;
      val = "" + val;
      if (val.search(/\//) !== -1) {
        _ref3 = val.split("/"), num = _ref3[0], denom = _ref3[1];
        val = this.precise.div(num, denom);
      }
      return val;
    };

    return Number;

  })(ExpressionComponent);

  ttm.class_mixer(Number);

  Exponentiation = (function(_super) {
    __extends(Exponentiation, _super);

    function Exponentiation() {
      _ref3 = Exponentiation.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Exponentiation.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Exponentiation.__super__.initialize.apply(this, arguments);
      this.baseval = opts.base.clone({
        parent: this
      });
      return this.powerval = opts.power.clone({
        parent: this
      });
    };

    Exponentiation.prototype.base = function() {
      return this.baseval;
    };

    Exponentiation.prototype.power = function() {
      return this.powerval;
    };

    Exponentiation.prototype.preceedingSubexpression = function() {
      return this.base();
    };

    Exponentiation.prototype.isExponentiation = function() {
      return true;
    };

    Exponentiation.prototype.updatePower = function(power) {
      return this.klass.build({
        base: this.base(),
        power: power
      });
    };

    Exponentiation.prototype.toString = function() {
      return "^(b: " + (this.base().toString()) + ", p: " + (this.power().toString()) + ")";
    };

    Exponentiation.prototype.subExpressions = function() {
      return [this.base(), this.power()];
    };

    Exponentiation.prototype.clone = function(new_vals) {
      var base_data, data, other;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        base: this.base().clone(),
        power: this.power().clone(),
        id: this.id_value
      };
      base_data = this.cloneData();
      other = this.klass.build(_.extend({}, base_data, data, new_vals));
      return other;
    };

    Exponentiation.prototype.replaceD = function(old_comp, new_comp) {
      this.baseval.replaceD(old_comp, new_comp);
      return this.powerval.replaceD(old_comp, new_comp);
    };

    return Exponentiation;

  })(ExpressionComponent);

  ttm.class_mixer(Exponentiation);

  Pi = (function(_super) {
    __extends(Pi, _super);

    function Pi() {
      _ref4 = Pi.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Pi.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Pi.__super__.initialize.apply(this, arguments);
      return this.pi_value = opts.value;
    };

    Pi.prototype.toString = function() {
      return "PI";
    };

    Pi.prototype.cloneData = function(new_vals) {
      var data;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        value: this.pi_value
      };
      return ttm.defaults(Pi.__super__.cloneData.apply(this, arguments), data);
    };

    Pi.prototype.isVariable = function() {
      return true;
    };

    Pi.prototype.value = function() {
      return this.pi_value || Math.PI;
    };

    return Pi;

  })(ExpressionComponent);

  ttm.class_mixer(Pi);

  Addition = (function(_super) {
    __extends(Addition, _super);

    function Addition() {
      _ref5 = Addition.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    Addition.prototype.toString = function() {
      return "Add";
    };

    return Addition;

  })(ExpressionComponent);

  ttm.class_mixer(Addition);

  Subtraction = (function(_super) {
    __extends(Subtraction, _super);

    function Subtraction() {
      _ref6 = Subtraction.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    Subtraction.prototype.toString = function() {
      return "Sub";
    };

    return Subtraction;

  })(ExpressionComponent);

  ttm.class_mixer(Subtraction);

  Multiplication = (function(_super) {
    __extends(Multiplication, _super);

    function Multiplication() {
      _ref7 = Multiplication.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    Multiplication.prototype.toString = function() {
      return "Mult";
    };

    Multiplication.prototype.isMultiplication = function() {
      return true;
    };

    return Multiplication;

  })(ExpressionComponent);

  ttm.class_mixer(Multiplication);

  Division = (function(_super) {
    __extends(Division, _super);

    function Division() {
      _ref8 = Division.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    Division.prototype.toString = function() {
      return "Div";
    };

    return Division;

  })(ExpressionComponent);

  ttm.class_mixer(Division);

  Fraction = (function(_super) {
    __extends(Fraction, _super);

    function Fraction() {
      _ref9 = Fraction.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    Fraction.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Fraction.__super__.initialize.apply(this, arguments);
      this.numerator_value = opts.numerator ? opts.numerator.withParent(this) : this.component_source.build_expression({
        parent: this
      });
      return this.denominator_value = opts.denominator ? opts.denominator.withParent(this) : this.component_source.build_expression({
        parent: this
      });
    };

    Fraction.prototype.toString = function() {
      return "Frac(num: " + (this.numerator().toString()) + ", den: " + (this.denominator().toString()) + ")";
    };

    Fraction.prototype.numerator = function() {
      return this.numerator_value;
    };

    Fraction.prototype.denominator = function() {
      return this.denominator_value;
    };

    Fraction.prototype.subExpressions = function() {
      return [this.numerator(), this.denominator()];
    };

    Fraction.prototype.isFraction = function() {
      return true;
    };

    Fraction.prototype.clone = function(new_vals) {
      var base_data, data, other;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        numerator: this.numerator().clone(),
        denominator: this.denominator().clone()
      };
      base_data = this.cloneData();
      other = this.klass.build(_.extend({}, base_data, data, new_vals));
      return other;
    };

    return Fraction;

  })(ExpressionComponent);

  ttm.class_mixer(Fraction);

  Blank = (function(_super) {
    __extends(Blank, _super);

    function Blank() {
      _ref10 = Blank.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    Blank.prototype.toString = function() {
      return "Blnk";
    };

    return Blank;

  })(ExpressionComponent);

  ttm.class_mixer(Blank);

  Root = (function(_super) {
    __extends(Root, _super);

    function Root() {
      _ref11 = Root.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    Root.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Root.__super__.initialize.apply(this, arguments);
      this.degree_value = opts.degree;
      return this.radicand_value = opts.radicand;
    };

    Root.prototype.toString = function() {
      return "Root(deg: " + (this.degree().toString()) + ", rad: " + (this.radicand().toString()) + ")";
    };

    Root.prototype.degree = function() {
      return this.degree_value;
    };

    Root.prototype.radicand = function() {
      return this.radicand_value;
    };

    Root.prototype.updateRadicand = function(new_radic) {
      return this.clone({
        radicand: new_radic
      });
    };

    Root.prototype.isRoot = function() {
      return true;
    };

    Root.prototype.cloneData = function(new_vals) {
      var data;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        degree: this.degree_value && this.degree_value.clone(),
        radicand: this.radicand_value && this.radicand_value.clone()
      };
      return ttm.defaults(Root.__super__.cloneData.apply(this, arguments), data);
    };

    Root.prototype.subExpressions = function() {
      return [this.degree(), this.radicand()];
    };

    Root.prototype.replaceD = function(old_comp, new_comp) {
      this.degree_value.replaceD(old_comp, new_comp);
      return this.radicand_value.replaceD(old_comp, new_comp);
    };

    return Root;

  })(ExpressionComponent);

  ttm.class_mixer(Root);

  Variable = (function(_super) {
    __extends(Variable, _super);

    function Variable() {
      _ref12 = Variable.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    Variable.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Variable.__super__.initialize.apply(this, arguments);
      return this.name_value = opts.name;
    };

    Variable.prototype.name = function() {
      return this.name_value;
    };

    Variable.prototype.clone = function(new_vals) {
      var base_data, data;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        name: this.name_value
      };
      base_data = this.cloneData();
      return this.klass.build(_.extend({}, base_data, data, new_vals));
    };

    Variable.prototype.toString = function() {
      return "Var(" + (this.name()) + ")";
    };

    Variable.prototype.isVariable = function() {
      return true;
    };

    return Variable;

  })(ExpressionComponent);

  ttm.class_mixer(Variable);

  Fn = (function(_super) {
    __extends(Fn, _super);

    function Fn() {
      _ref13 = Fn.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    Fn.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      Fn.__super__.initialize.apply(this, arguments);
      this.name_value = opts.name;
      return this.argument_value = opts.argument;
    };

    Fn.prototype.cloneData = function(new_vals) {
      if (new_vals == null) {
        new_vals = {};
      }
      return ttm.defaults(Fn.__super__.cloneData.apply(this, arguments), {
        name: this.name_value,
        argument: this.argument() && this.argument().clone()
      });
    };

    Fn.prototype.subExpressions = function() {
      return [this.argument()];
    };

    Fn.prototype.toString = function() {
      return "Fn(name: " + (this.name()) + ", argument: " + (this.argument().toString()) + ")";
    };

    Fn.prototype.argument = function() {
      return this.argument_value;
    };

    Fn.prototype.name = function() {
      return this.name_value;
    };

    return Fn;

  })(ExpressionComponent);

  ttm.class_mixer(Fn);

  ExpressionIDSource = (function() {
    function ExpressionIDSource() {}

    ExpressionIDSource.prototype.initialize = function() {
      return this.id = 0;
    };

    ExpressionIDSource.prototype.next = function() {
      var next;
      next = ++this.id;
      return next;
    };

    ExpressionIDSource.prototype.current = function() {
      return this.id;
    };

    return ExpressionIDSource;

  })();

  ttm.class_mixer(ExpressionIDSource);

  components = {
    expression: Expression,
    addition: Addition,
    number: Number,
    multiplication: Multiplication,
    division: Division,
    subtraction: Subtraction,
    exponentiation: Exponentiation,
    pi: Pi,
    equals: Equals,
    blank: Blank,
    root: Root,
    variable: Variable,
    fraction: Fraction,
    fn: Fn
  };

  ExpressionComponentSource = (function() {
    function ExpressionComponentSource() {}

    ExpressionComponentSource.prototype.initialize = function(precise_lib) {
      this.id_source = ExpressionIDSource.build();
      return this.precise_lib = precise_lib;
    };

    ExpressionComponentSource.prototype.classes = components;

    return ExpressionComponentSource;

  })();

  for (name in components) {
    klass = components[name];
    if (name === "number") {
      continue;
    }
    build_klass = (function(name, klass) {
      return function(opts) {
        if (opts == null) {
          opts = {};
        }
        opts.id || (opts.id = this.id_source.next());
        opts.component_source = this;
        return klass.build(opts);
      };
    })(name, klass);
    ExpressionComponentSource.prototype["build_" + name] = build_klass;
  }

  ExpressionComponentSource.prototype.build_number = function(opts) {
    if (opts == null) {
      opts = {};
    }
    opts.id || (opts.id = this.id_source.next());
    opts.precise_lib || (opts.precise_lib = this.precise_lib);
    return Number.build(opts);
  };

  ttm.lib.math.ExpressionComponentSource = ttm.class_mixer(ExpressionComponentSource);

}).call(this);

},{}],5:[function(require,module,exports){
(function() {
  var ExpressionEquality, buildIsEqual, class_mixer, comps, object_refinement, ref, ttm;

  ttm = thinkthroughmath;

  class_mixer = ttm.class_mixer;

  object_refinement = ttm.lib.object_refinement;

  ref = object_refinement.build();

  comps = ttm.lib.math.ExpressionComponentSource.build();

  buildIsEqual = function(for_type, additional_method) {
    var isEqualFunction;
    if (additional_method == null) {
      additional_method = false;
    }
    isEqualFunction = function(other, eq_calc) {
      var same_type;
      same_type = other instanceof for_type;
      eq_calc.saveFalseForReport(same_type, this.unrefined(), other, "different types " + for_type.name);
      if (same_type) {
        if (additional_method) {
          return this[additional_method](other, eq_calc);
        } else {
          return true;
        }
      } else {
        return false;
      }
    };
    return ttm.logger.instrument({
      name: "buildIsEqual function",
      fn: isEqualFunction
    });
  };

  ref.forType(comps.classes.addition, {
    isEqual: buildIsEqual(comps.classes.addition)
  });

  ref.forType(comps.classes.blank, {
    isEqual: buildIsEqual(comps.classes.blank)
  });

  ref.forType(comps.classes.division, {
    isEqual: buildIsEqual(comps.classes.division)
  });

  ref.forType(comps.classes.exponentiation, {
    isEqual: buildIsEqual(comps.classes.exponentiation, "checkBaseAndPowerEquality"),
    checkBaseAndPowerEquality: function(other, eq_comp) {
      var base_equal, power_equal;
      base_equal = ref.refine(this.base()).isEqual(other.base(), eq_comp);
      power_equal = ref.refine(this.power()).isEqual(other.power(), eq_comp);
      return base_equal && power_equal;
    }
  });

  ref.forType(comps.classes.expression, {
    isExpressionEqual: function(other, eq_calc) {
      var contains_unequal, match_error, match_open, match_size;
      ttm.logger.info("isExpressionEqual", this.unrefined(), other);
      match_error = this.is_error === other.is_error;
      eq_calc.saveFalseForReport(match_error, this.unrefined(), other, "error values not equal");
      match_open = this.is_open === other.is_open;
      eq_calc.saveFalseForReport(match_open, this.unrefined(), other, "open values not equal");
      if (match_error && match_open) {
        contains_unequal = _.chain(this.expression).map(function(element, i) {
          var ret;
          ret = ref.refine(element).isEqual(other.nth(i), eq_calc);
          return ret;
        }).contains(false).value();
        if (contains_unequal) {
          return false;
        } else {
          match_size = _(this.expression).size() === _(other.expression).size();
          return eq_calc.saveFalseForReport(match_size, this.unrefined(), other, "size values not equal");
        }
      } else {
        return false;
      }
    },
    isEqual: function(other, eq_calc) {
      var same_type;
      same_type = eq_calc.saveFalseForReport(other instanceof comps.classes.expression, this.unrefined(), other, "Wrong types");
      if (same_type) {
        return this.isExpressionEqual(other, eq_calc);
      } else {
        return false;
      }
    }
  });

  ref.forType(comps.classes.equals, {
    isEqual: buildIsEqual(comps.classes.equals)
  });

  ref.forType(comps.classes.fn, {
    isEqual: buildIsEqual(comps.classes.fn, "checkNameAndArgumentEquality"),
    checkNameAndArgumentEquality: function(other, eq_comp) {
      var argument_equal, name_equal;
      name_equal = this.name() === other.name();
      argument_equal = ref.refine(this.argument()).isEqual(other.argument(), eq_comp);
      return name_equal && argument_equal;
    }
  });

  ref.forType(comps.classes.fraction, {
    isEqual: buildIsEqual(comps.classes.fraction, "checkNumeratorAndDenominatorEquality"),
    checkNumeratorAndDenominatorEquality: function(other, eq_comp) {
      var denominator_equal, numerator_equal;
      numerator_equal = ref.refine(this.numerator()).isEqual(other.numerator(), eq_comp);
      denominator_equal = ref.refine(this.denominator()).isEqual(other.denominator(), eq_comp);
      return numerator_equal && denominator_equal;
    }
  });

  ref.forType(comps.classes.multiplication, {
    isEqual: buildIsEqual(comps.classes.multiplication)
  });

  ref.forType(comps.classes.number, {
    isEqual: buildIsEqual(comps.classes.number, "checkNumberValues"),
    checkNumberValues: function(other, eq_calc) {
      var check;
      check = parseFloat("" + (this.value())).toFixed(2) === parseFloat("" + (other.value())).toFixed(2);
      return eq_calc.saveFalseForReport(check, this.unrefined(), other, "Numeric values not equal");
    }
  });

  ref.forDefault({
    isEqual: function() {
      console.log(this);
      throw "NOT IMPLEMENTED";
    }
  });

  ref.forType(comps.classes.pi, {
    isEqual: buildIsEqual(comps.classes.pi)
  });

  ref.forType(comps.classes.subtraction, {
    isEqual: buildIsEqual(comps.classes.subtraction)
  });

  ref.forType(comps.classes.root, {
    isEqual: buildIsEqual(comps.classes.root, "checkDegreeAndRadicand"),
    checkDegreeAndRadicand: function(other, eq_calc) {
      var degree_equal, radicand_equal;
      degree_equal = ref.refine(this.degree()).isEqual(other.degree(), eq_calc);
      radicand_equal = ref.refine(this.radicand()).isEqual(other.radicand(), eq_calc);
      return degree_equal && radicand_equal;
    }
  });

  ref.forType(comps.classes.variable, {
    isEqual: buildIsEqual(comps.classes.variable, "checkNames"),
    checkNames: function(other, eq_calc) {
      var check;
      check = ("" + (this.name())) === ("" + (other.name()));
      return eq_calc.saveFalseForReport(check, this.unrefined(), other, "Variable names not equal");
    }
  });

  ref.forDefault({
    isEqual: function() {
      throw ["Unimplemented equality refinement for ", this.unrefined()];
    }
  });

  ExpressionEquality = (function() {
    function ExpressionEquality() {}

    ExpressionEquality.prototype.initialize = function() {
      return this.report_saved = false;
    };

    ExpressionEquality.prototype.calculate = function(first, second) {
      var firstp;
      this.first = first;
      this.second = second;
      firstp = ref.refine(this.first);
      this._equality_results = firstp.isEqual(this.second, this);
      return this;
    };

    ExpressionEquality.prototype.isEqual = function() {
      return this._equality_results;
    };

    ExpressionEquality.prototype.notEqualReport = function(a, b, not_eql_msg) {
      this.a = a;
      this.b = b;
      this.not_eql_msg = not_eql_msg;
      return this.report_saved = true;
    };

    ExpressionEquality.prototype.saveFalseForReport = function(value, a, b, msg) {
      if (value) {
        return true;
      } else {
        if (!this.report_saved) {
          this.notEqualReport(a, b, msg);
        }
        return false;
      }
    };

    return ExpressionEquality;

  })();

  class_mixer(ExpressionEquality);

  ExpressionEquality.isEqual = function(a, b) {
    return ExpressionEquality.build().calculate(a, b).isEqual();
  };

  ExpressionEquality.equalityCalculation = function(a, b) {
    var ec;
    ec = ExpressionEquality.build();
    ec.calculate(a, b);
    return ec;
  };

  ttm.lib.math.ExpressionEquality = ExpressionEquality;

}).call(this);

},{}],6:[function(require,module,exports){
(function() {
  var EvaluationRefinementBuilder, ExpressionEvaluation, MalformedExpressionError, class_mixer, comps, logger, object_refinement, ttm;

  ttm = thinkthroughmath;

  logger = ttm.logger;

  class_mixer = ttm.class_mixer;

  object_refinement = ttm.lib.object_refinement;

  EvaluationRefinementBuilder = (function() {
    function EvaluationRefinementBuilder() {}

    EvaluationRefinementBuilder.prototype.initialize = function(comps, class_mixer, object_refinement, MalformedExpressionError, precise) {
      var ExpressionEvaluationPass, refinement;
      comps = comps;
      refinement = object_refinement.build();
      refinement.forType(comps.classes.number, {
        "eval": function() {
          return this;
        }
      });
      refinement.forType(comps.classes.exponentiation, {
        "eval": function(evaluation, pass) {
          var base, power;
          if (pass !== "exponentiation") {
            return;
          }
          if (!this.base().isEmpty() && !this.power().isEmpty()) {
            base = refinement.refine(this.base())["eval"]().toCalculable();
            power = refinement.refine(this.power())["eval"]().toCalculable();
            ttm.logger.info("exponentiation", base, power);
            return comps.classes.number.build({
              value: Math.pow(base, power)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      refinement.forType(comps.classes.pi, {
        "eval": function() {
          return comps.classes.number.build({
            value: this.value()
          });
        }
      });
      refinement.forType(comps.classes.addition, {
        "eval": function(evaluation, pass) {
          var next, prev;
          if (pass !== "addition") {
            return;
          }
          prev = evaluation.previousValue();
          next = evaluation.nextValue();
          if (prev && next) {
            evaluation.handledSurrounding();
            return comps.classes.number.build({
              value: precise.add(prev, next)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      refinement.forType(comps.classes.subtraction, {
        "eval": function(evaluation, pass) {
          var next, prev;
          if (pass !== "addition") {
            return;
          }
          prev = evaluation.previousValue();
          next = evaluation.nextValue();
          if (prev && next) {
            evaluation.handledSurrounding();
            return comps.classes.number.build({
              value: precise.sub(prev, next)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      refinement.forType(comps.classes.multiplication, {
        "eval": function(evaluation, pass) {
          var next, prev;
          if (pass !== "multiplication") {
            return;
          }
          prev = evaluation.previousValue();
          next = evaluation.nextValue();
          if (prev && next) {
            evaluation.handledSurrounding();
            return comps.classes.number.build({
              value: precise.mul(prev, next)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      refinement.forType(comps.classes.division, {
        "eval": function(evaluation, pass) {
          var next, prev;
          if (pass !== "multiplication") {
            return;
          }
          prev = evaluation.previousValue();
          next = evaluation.nextValue();
          if (prev && next) {
            evaluation.handledSurrounding();
            return comps.classes.number.build({
              value: precise.div(prev, next)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      refinement.forType(comps.classes.fraction, {
        "eval": function(evaluation, pass) {
          var denom, num;
          if (pass !== "multiplication") {
            return;
          }
          num = refinement.refine(this.numerator())["eval"]().toCalculable();
          denom = refinement.refine(this.denominator())["eval"]().toCalculable();
          if (num && denom) {
            return comps.build_number({
              value: precise.div(num, denom)
            });
          } else {
            throw new MalformedExpressionError("Invalid Expression");
          }
        }
      });
      this.refinement_val = refinement;
      ExpressionEvaluationPass = (function() {
        function ExpressionEvaluationPass() {}

        ExpressionEvaluationPass.prototype.initialize = function(expression) {
          this.expression = expression;
          return this.expression_index = -1;
        };

        ExpressionEvaluationPass.prototype.perform = function(pass_type) {
          var eval_ret, exp, ret;
          ret = [];
          this.expression_index = 0;
          while (this.expression.length > this.expression_index) {
            exp = refinement.refine(this.expression[this.expression_index]);
            eval_ret = exp["eval"](this, pass_type);
            if (eval_ret) {
              this.expression[this.expression_index] = eval_ret;
            }
            this.expression_index += 1;
          }
          return this.expression;
        };

        ExpressionEvaluationPass.prototype.previousValue = function() {
          var prev;
          prev = this.expression[this.expression_index - 1];
          if (prev) {
            return prev.value();
          }
        };

        ExpressionEvaluationPass.prototype.nextValue = function() {
          var next;
          next = this.expression[this.expression_index + 1];
          if (next) {
            return next.value();
          }
        };

        ExpressionEvaluationPass.prototype.handledPrevious = function() {
          this.expression.splice(this.expression_index - 1, 1);
          return this.expression_index -= 1;
        };

        ExpressionEvaluationPass.prototype.handledSurrounding = function() {
          this.handledPrevious();
          return this.expression.splice(this.expression_index + 1, 1);
        };

        return ExpressionEvaluationPass;

      })();
      class_mixer(ExpressionEvaluationPass);
      return refinement.forType(comps.classes.expression, {
        "eval": function() {
          var expr;
          expr = this.expression;
          logger.info("before parenthetical", expr);
          expr = ExpressionEvaluationPass.build(expr).perform("parenthetical");
          logger.info("before exponentiation", expr);
          expr = ExpressionEvaluationPass.build(expr).perform("exponentiation");
          logger.info("before multiplication", expr);
          expr = ExpressionEvaluationPass.build(expr).perform("multiplication");
          logger.info("before addition", expr);
          expr = ExpressionEvaluationPass.build(expr).perform("addition");
          logger.info("before returning", expr);
          return _(expr).first();
        }
      });
    };

    EvaluationRefinementBuilder.prototype.refinement = function() {
      return this.refinement_val;
    };

    return EvaluationRefinementBuilder;

  })();

  ttm.class_mixer(EvaluationRefinementBuilder);

  MalformedExpressionError = function(message) {
    this.name = 'MalformedExpressionError';
    this.message = message;
    return this.stack = (new Error()).stack;
  };

  MalformedExpressionError.prototype = new Error;

  comps = ttm.lib.math.ExpressionComponentSource.build();

  ExpressionEvaluation = (function() {
    function ExpressionEvaluation() {}

    ExpressionEvaluation.prototype.initialize = function(expression, opts) {
      this.expression = expression;
      this.opts = opts != null ? opts : {};
      this.comps = this.opts.comps || comps;
      this.precise = ttm.lib.math.Precise.build();
      return this.refinement = EvaluationRefinementBuilder.build(this.comps, class_mixer, object_refinement, MalformedExpressionError, this.precise).refinement();
    };

    ExpressionEvaluation.prototype.resultingExpression = function() {
      var e, results;
      results = false;
      try {
        results = this.evaluate();
      } catch (_error) {
        e = _error;
        if (!(e instanceof MalformedExpressionError)) {
          throw e;
        }
      }
      if (results) {
        return this.comps.build_expression({
          expression: [results]
        });
      } else {
        return this.expression.clone({
          is_error: true
        });
      }
    };

    ExpressionEvaluation.prototype.evaluate = function() {
      var refined, results;
      refined = this.refinement.refine(this.expression);
      return results = refined["eval"]();
    };

    return ExpressionEvaluation;

  })();

  class_mixer(ExpressionEvaluation);

  ttm.lib.math.ExpressionEvaluation = ExpressionEvaluation;

}).call(this);

},{}],7:[function(require,module,exports){
(function() {
  var AppendAddition, AppendDecimal, AppendDivision, AppendEquals, AppendExponentiation, AppendFn, AppendFraction, AppendMultiplication, AppendNumber, AppendPi, AppendRoot, AppendSubExpression, AppendSubtraction, AppendVariable, Calculate, ExitSubExpression, ExponentiateLast, ExpressionManipulation, ExpressionManipulationSource, ExpressionPositionManipulator, GetLeftSide, GetRightSide, NegateLast, RemovePointedAt, Reset, Square, SquareRoot, SubstituteVariables, UpdatePosition, build_klass, class_mixer, exports, expression_evaluation, klass, name, object_refinement, ttm, _ExpressionManipulator, _FinalOpenSubExpressionApplication, _ImplicitMultiplication, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ttm = thinkthroughmath;

  class_mixer = ttm.class_mixer;

  expression_evaluation = ttm.lib.math.ExpressionEvaluation;

  object_refinement = ttm.lib.object_refinement;

  _FinalOpenSubExpressionApplication = (function() {
    function _FinalOpenSubExpressionApplication() {}

    _FinalOpenSubExpressionApplication.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.comps = opts.comps;
      this.expr = opts.expr;
      return this.found = false;
    };

    _FinalOpenSubExpressionApplication.prototype.findAndPerformAction = function(expr) {
      var subexp;
      subexp = this.nextSubExpression(expr);
      if (subexp) {
        subexp = this.findAndPerformAction(subexp);
      }
      if (this.found) {
        return this.updateWithNewSubexp(expr, subexp);
      } else if (expr instanceof this.comps.classes.expression && expr.isOpen()) {
        this.found = true;
        return this.action(expr);
      } else {
        return expr;
      }
    };

    _FinalOpenSubExpressionApplication.prototype.perform = function(action) {
      this.action = action;
      return this.findAndPerformAction(this.expr);
    };

    _FinalOpenSubExpressionApplication.prototype.wasFound = function() {
      return this.found;
    };

    _FinalOpenSubExpressionApplication.prototype.updateWithNewSubexp = function(expr, subexp) {
      if (expr instanceof this.comps.classes.expression) {
        return expr.replaceLast(subexp);
      } else if (expr instanceof this.comps.classes.exponentiation) {
        return expr.updatePower(subexp);
      } else if (expr instanceof this.comps.classes.root) {
        return expr.updateRadicand(subexp);
      }
    };

    _FinalOpenSubExpressionApplication.prototype.nextSubExpression = function(expr) {
      if (expr instanceof this.comps.classes.expression) {
        return expr.last();
      } else if (expr instanceof this.comps.classes.exponentiation) {
        return expr.power();
      } else if (expr instanceof this.comps.classes.root) {
        return expr.radicand();
      } else {
        return false;
      }
    };

    _FinalOpenSubExpressionApplication.prototype.performOrDefault = function(action) {
      var result;
      this.action = action;
      result = this.findAndPerformAction(this.expr);
      if (this.wasFound()) {
        return result;
      } else {
        return this.action(this.expr);
      }
    };

    return _FinalOpenSubExpressionApplication;

  })();

  class_mixer(_FinalOpenSubExpressionApplication);

  _ImplicitMultiplication = (function() {
    function _ImplicitMultiplication() {}

    _ImplicitMultiplication.prototype.initialize = function(comps) {
      this.comps = comps;
    };

    _ImplicitMultiplication.prototype.invokeD = function(expression) {
      var last;
      last = expression.last();
      if (last && (last.isNumber() || last.isExpression() || last.isVariable() || last.isFraction() || last.isExponentiation() || last.isRoot())) {
        expression.appendD(this.comps.build_multiplication());
        return expression;
      } else {
        return expression;
      }
    };

    return _ImplicitMultiplication;

  })();

  class_mixer(_ImplicitMultiplication);

  _ExpressionManipulator = (function() {
    function _ExpressionManipulator() {}

    _ExpressionManipulator.prototype.initialize = function(expr, traversal) {
      this.expr = expr;
      this.traversal = traversal;
    };

    _ExpressionManipulator.prototype.clone = function() {
      this.expr = this.expr.clone();
      return this;
    };

    _ExpressionManipulator.prototype.withComponent = function(position, fn) {
      var comp;
      comp = this.traversal.build(this.expr).findForID(position.position());
      fn(comp);
      return this;
    };

    _ExpressionManipulator.prototype.value = function() {
      return this.expr;
    };

    return _ExpressionManipulator;

  })();

  class_mixer(_ExpressionManipulator);

  ExpressionManipulation = (function() {
    function ExpressionManipulation() {}

    ExpressionManipulation.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.comps = opts.comps;
      this.pos = opts.pos;
      return this.traversal = opts.traversal;
    };

    ExpressionManipulation.prototype.evaluate = function(exp) {
      var ret;
      return ret = expression_evaluation.build(exp).resultingExpression();
    };

    ExpressionManipulation.prototype.value = function(exp) {
      var result;
      result = expression_evaluation.build(exp).evaluate();
      if (result) {
        return result.value();
      } else {
        return 0;
      }
    };

    ExpressionManipulation.prototype.M = function(expr) {
      this.expr = expr;
      return _ExpressionManipulator.build(this.expr, this.traversal);
    };

    ExpressionManipulation.prototype.isOperator = function(comp) {
      var c;
      c = this.comps.classes;
      switch (comp.klass) {
        case c.equals:
        case c.addition:
        case c.subtraction:
        case c.multiplication:
        case c.division:
          return true;
        default:
          return false;
      }
    };

    ExpressionManipulation.prototype.withoutTrailingOperatorD = function(exp) {
      if (this.isOperator(exp.last())) {
        exp.withoutLastD();
      }
      return exp;
    };

    return ExpressionManipulation;

  })();

  ExpressionPositionManipulator = (function() {
    function ExpressionPositionManipulator() {}

    ExpressionPositionManipulator.prototype.initialize = function(traversal) {
      this.traversal = traversal;
    };

    ExpressionPositionManipulator.prototype.updatePositionTo = function(exp_pos, callback) {
      var found, new_pos_id,
        _this = this;
      exp_pos = exp_pos.clone();
      found = false;
      new_pos_id = false;
      this.traversal.build(exp_pos).each(function(comp) {
        var cb_results;
        if (!found) {
          cb_results = callback(comp);
          if (cb_results) {
            new_pos_id = comp.id();
            return found = true;
          }
        }
      });
      return exp_pos.clone({
        position: new_pos_id
      });
    };

    return ExpressionPositionManipulator;

  })();

  class_mixer(ExpressionPositionManipulator);

  Calculate = (function(_super) {
    __extends(Calculate, _super);

    function Calculate() {
      _ref = Calculate.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Calculate.prototype.perform = function(expression_position) {
      var results;
      results = this.evaluate(expression_position.expression());
      return expression_position.clone({
        expression: results,
        position: results.id()
      });
    };

    return Calculate;

  })(ExpressionManipulation);

  class_mixer(Calculate);

  Square = (function(_super) {
    __extends(Square, _super);

    function Square() {
      _ref1 = Square.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Square.prototype.perform = function(expression_position) {
      var new_exp, val;
      val = this.value(expression_position.expression());
      new_exp = this.comps.build_expression({
        expression: [
          this.comps.build_number({
            value: val * val
          })
        ]
      });
      return this.pos.build({
        expression: new_exp,
        position: new_exp.id()
      });
    };

    return Square;

  })(ExpressionManipulation);

  class_mixer(Square);

  AppendDecimal = (function(_super) {
    __extends(AppendDecimal, _super);

    function AppendDecimal() {
      _ref2 = AppendDecimal.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    AppendDecimal.prototype.doAppendD = function(expression, expression_position) {
      var last, new_last;
      last = expression.last();
      if (last) {
        if (last.isNumber()) {
          return last.futureAsDecimalD(true);
        } else {
          _ImplicitMultiplication.build(this.comps).invokeD(expression);
          new_last = this.comps.build_number({
            value: 0
          });
          new_last.futureAsDecimalD(true);
          return expression.appendD(new_last);
        }
      } else {
        new_last = this.comps.build_number({
          value: 0
        });
        new_last.futureAsDecimalD(true);
        return expression.appendD(new_last);
      }
    };

    AppendDecimal.prototype.perform = function(expression_position) {
      var result_exp,
        _this = this;
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.doAppendD(component, expression_position);
      }).value();
      return result_exp;
    };

    return AppendDecimal;

  })(ExpressionManipulation);

  class_mixer(AppendDecimal);

  AppendNumber = (function(_super) {
    __extends(AppendNumber, _super);

    function AppendNumber() {
      _ref3 = AppendNumber.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    AppendNumber.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendNumber.__super__.initialize.apply(this, arguments);
      return this.val = opts.value;
    };

    AppendNumber.prototype.doAppendD = function(append_to, expression_position) {
      var last, number_to_append;
      number_to_append = this.comps.build_number({
        value: this.val
      });
      last = append_to.last();
      if (last) {
        if (last instanceof this.comps.classes.number) {
          return append_to.last().concatenateD(this.val);
        } else if ((last instanceof this.comps.classes.exponentiation) || !this.isOperator(last)) {
          append_to.appendD(this.comps.build_multiplication());
          return append_to.appendD(number_to_append);
        } else {
          return append_to.appendD(number_to_append);
        }
      } else {
        return append_to.appendD(number_to_append);
      }
    };

    AppendNumber.prototype.perform = function(expression_position) {
      var result_exp,
        _this = this;
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.doAppendD(component, expression_position);
      }).value();
      return result_exp;
    };

    return AppendNumber;

  })(ExpressionManipulation);

  class_mixer(AppendNumber);

  ExponentiateLast = (function(_super) {
    __extends(ExponentiateLast, _super);

    function ExponentiateLast() {
      _ref4 = ExponentiateLast.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    ExponentiateLast.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      ExponentiateLast.__super__.initialize.apply(this, arguments);
      return this.power = opts.power;
    };

    ExponentiateLast.prototype.baseExpression = function(base) {
      if (base instanceof this.comps.classes.expression) {
        return base;
      } else {
        return this.comps.build_expression({
          expression: [base]
        });
      }
    };

    ExponentiateLast.prototype.powerExpression = function() {
      var power;
      power = this.power ? this.comps.build_expression({
        expression: [
          this.comps.build_number({
            value: this.power
          })
        ]
      }) : this.comps.build_expression({
        expression: []
      });
      return power;
    };

    ExponentiateLast.prototype.exponentiateLastOfComponent = function(component) {
      var base, it, last, power;
      if (component.isEmpty()) {
        return;
      }
      last = component.last();
      if (it = last.preceedingSubexpression()) {
        base = this.baseExpression(it);
      } else if (this.isOperator(last)) {
        component.withoutLastD();
        base = this.baseExpression(component.last());
      } else {
        base = this.baseExpression(component.last());
      }
      power = this.powerExpression();
      this.pos_id = this.posID(power, component);
      return component.replaceLastD(this.comps.build_exponentiation({
        base: base,
        power: power
      }));
    };

    ExponentiateLast.prototype.posID = function(power, component) {
      return power.id();
    };

    ExponentiateLast.prototype.perform = function(expression_position) {
      var expression, result_exp,
        _this = this;
      expression = expression_position.expression();
      if (expression.isEmpty()) {
        return expression_position;
      }
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.exponentiateLastOfComponent(component);
      }).value();
      return result_exp.clone({
        position: this.pos_id
      });
    };

    return ExponentiateLast;

  })(ExpressionManipulation);

  class_mixer(ExponentiateLast);

  AppendExponentiation = (function(_super) {
    __extends(AppendExponentiation, _super);

    function AppendExponentiation() {
      _ref5 = AppendExponentiation.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    AppendExponentiation.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendExponentiation.__super__.initialize.apply(this, arguments);
      return this.exponent_content = opts.power;
    };

    AppendExponentiation.prototype.perform = function(expression_position) {
      var base, exp, exponentiation, power, result_exp,
        _this = this;
      exp = this.exponent_content ? [
        this.comps.build_number({
          value: this.exponent_content
        })
      ] : [];
      base = this.comps.build_expression();
      power = this.comps.build_expression({
        expression: exp
      });
      exponentiation = this.comps.build_exponentiation({
        base: base,
        power: power
      });
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(exponentiation);
      }).value();
      return result_exp.clone({
        position: base.id()
      });
    };

    return AppendExponentiation;

  })(ExpressionManipulation);

  class_mixer(AppendExponentiation);

  AppendMultiplication = (function(_super) {
    __extends(AppendMultiplication, _super);

    function AppendMultiplication() {
      _ref6 = AppendMultiplication.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    AppendMultiplication.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      if (expr.isEmpty()) {
        return expression_position;
      }
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(_this.comps.build_multiplication());
      }).value();
      return result_exp;
    };

    return AppendMultiplication;

  })(ExpressionManipulation);

  class_mixer(AppendMultiplication);

  AppendEquals = (function(_super) {
    __extends(AppendEquals, _super);

    function AppendEquals() {
      _ref7 = AppendEquals.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    AppendEquals.prototype.perform = function(expression_position) {
      var equals, result_exp,
        _this = this;
      expression_position = expression_position.clone({
        position: expression_position.expression().id()
      });
      equals = this.comps.build_equals();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(equals);
      }).value();
      return result_exp;
    };

    return AppendEquals;

  })(ExpressionManipulation);

  class_mixer(AppendEquals);

  AppendDivision = (function(_super) {
    __extends(AppendDivision, _super);

    function AppendDivision() {
      _ref8 = AppendDivision.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    AppendDivision.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      if (expr.isEmpty()) {
        return expression_position;
      }
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(_this.comps.build_division());
      }).value();
      return result_exp;
    };

    return AppendDivision;

  })(ExpressionManipulation);

  class_mixer(AppendDivision);

  AppendAddition = (function(_super) {
    __extends(AppendAddition, _super);

    function AppendAddition() {
      _ref9 = AppendAddition.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    AppendAddition.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      if (expr.isEmpty()) {
        return expression_position;
      }
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(_this.comps.build_addition());
      }).value();
      return result_exp;
    };

    return AppendAddition;

  })(ExpressionManipulation);

  class_mixer(AppendAddition);

  AppendSubtraction = (function(_super) {
    __extends(AppendSubtraction, _super);

    function AppendSubtraction() {
      _ref10 = AppendSubtraction.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    AppendSubtraction.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(_this.comps.build_subtraction());
      }).value();
      return result_exp;
    };

    return AppendSubtraction;

  })(ExpressionManipulation);

  class_mixer(AppendSubtraction);

  AppendDivision = (function(_super) {
    __extends(AppendDivision, _super);

    function AppendDivision() {
      _ref11 = AppendDivision.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    AppendDivision.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      if (expr.isEmpty()) {
        return expression_position;
      }
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.withoutTrailingOperatorD(component).appendD(_this.comps.build_division());
      }).value();
      return result_exp;
    };

    return AppendDivision;

  })(ExpressionManipulation);

  class_mixer(AppendDivision);

  NegateLast = (function(_super) {
    __extends(NegateLast, _super);

    function NegateLast() {
      _ref12 = NegateLast.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    NegateLast.prototype.negateComp = function(comp) {
      var last;
      last = comp.last();
      if (last instanceof this.comps.classes.number) {
        return last.negatedD();
      }
    };

    NegateLast.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return _this.negateComp(component);
      }).value();
      return result_exp;
    };

    return NegateLast;

  })(ExpressionManipulation);

  class_mixer(NegateLast);

  AppendSubExpression = (function(_super) {
    __extends(AppendSubExpression, _super);

    function AppendSubExpression() {
      _ref13 = AppendSubExpression.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    AppendSubExpression.prototype.perform = function(expression_position) {
      var expr, new_exp, result_exp,
        _this = this;
      expr = expression_position.expression();
      new_exp = this.comps.build_expression();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(new_exp);
      }).value();
      return result_exp.clone({
        position: new_exp.id()
      });
    };

    return AppendSubExpression;

  })(ExpressionManipulation);

  class_mixer(AppendSubExpression);

  ExitSubExpression = (function(_super) {
    __extends(ExitSubExpression, _super);

    function ExitSubExpression() {
      _ref14 = ExitSubExpression.__super__.constructor.apply(this, arguments);
      return _ref14;
    }

    ExitSubExpression.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        var parent;
        parent = component.parent();
        if (parent) {
          if (parent.isExpression()) {
            return _this.position_id = parent.id();
          } else {
            return _this.position_id = parent.parent().id();
          }
        } else {
          return _this.position_id = component.id();
        }
      }).value();
      return result_exp.clone({
        position: this.position_id
      });
    };

    return ExitSubExpression;

  })(ExpressionManipulation);

  class_mixer(ExitSubExpression);

  AppendPi = (function(_super) {
    __extends(AppendPi, _super);

    function AppendPi() {
      _ref15 = AppendPi.__super__.constructor.apply(this, arguments);
      return _ref15;
    }

    AppendPi.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendPi.__super__.initialize.apply(this, arguments);
      return this.pi_value = opts.value;
    };

    AppendPi.prototype.perform = function(expression_position) {
      var expr, result_exp,
        _this = this;
      expr = expression_position.expression();
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(_this.comps.build_pi({
          value: _this.pi_value
        }));
      }).value();
      return result_exp;
    };

    return AppendPi;

  })(ExpressionManipulation);

  class_mixer(AppendPi);

  AppendRoot = (function(_super) {
    __extends(AppendRoot, _super);

    function AppendRoot() {
      _ref16 = AppendRoot.__super__.constructor.apply(this, arguments);
      return _ref16;
    }

    AppendRoot.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendRoot.__super__.initialize.apply(this, arguments);
      return this.degree = opts.degree;
    };

    AppendRoot.prototype.perform = function(expression_position) {
      var degree, radicand, result_exp, root,
        _this = this;
      degree = this.degree ? this.comps.build_expression({
        expression: [
          this.comps.build_number({
            value: this.degree
          })
        ]
      }) : this.comps.build_expression();
      radicand = this.comps.build_expression({
        expression: []
      });
      root = this.comps.build_root({
        degree: degree,
        radicand: radicand
      });
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(root);
      }).value();
      return result_exp.clone({
        position: radicand.id()
      });
    };

    return AppendRoot;

  })(ExpressionManipulation);

  class_mixer(AppendRoot);

  AppendVariable = (function(_super) {
    __extends(AppendVariable, _super);

    function AppendVariable() {
      _ref17 = AppendVariable.__super__.constructor.apply(this, arguments);
      return _ref17;
    }

    AppendVariable.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendVariable.__super__.initialize.apply(this, arguments);
      return this.variable_name = opts.variable;
    };

    AppendVariable.prototype.perform = function(expression_position) {
      var expr, result_exp, variable,
        _this = this;
      expr = expression_position.expression();
      variable = this.comps.build_variable({
        name: this.variable_name
      });
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(variable);
      }).value();
      return result_exp;
    };

    return AppendVariable;

  })(ExpressionManipulation);

  class_mixer(AppendVariable);

  AppendFraction = (function(_super) {
    __extends(AppendFraction, _super);

    function AppendFraction() {
      _ref18 = AppendFraction.__super__.constructor.apply(this, arguments);
      return _ref18;
    }

    AppendFraction.prototype.perform = function(expression_position) {
      var denominator, exp, fraction, numerator, result_exp,
        _this = this;
      exp = expression_position.expression();
      numerator = this.comps.build_expression();
      denominator = this.comps.build_expression();
      fraction = this.comps.build_fraction({
        numerator: numerator,
        denominator: denominator
      });
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(fraction);
      }).value();
      return result_exp.clone({
        position: numerator.id()
      });
    };

    return AppendFraction;

  })(ExpressionManipulation);

  class_mixer(AppendFraction);

  AppendFn = (function(_super) {
    __extends(AppendFn, _super);

    function AppendFn() {
      _ref19 = AppendFn.__super__.constructor.apply(this, arguments);
      return _ref19;
    }

    AppendFn.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      AppendFn.__super__.initialize.apply(this, arguments);
      return this.name = opts.name;
    };

    AppendFn.prototype.perform = function(expression_position) {
      var argument, exp, fn, result_exp,
        _this = this;
      exp = expression_position.expression();
      argument = this.comps.build_expression();
      fn = this.comps.build_fn({
        name: this.name,
        argument: argument
      });
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        _ImplicitMultiplication.build(_this.comps).invokeD(component);
        return component.appendD(fn);
      }).value();
      return result_exp;
    };

    return AppendFn;

  })(ExpressionManipulation);

  class_mixer(AppendFn);

  SquareRoot = (function(_super) {
    __extends(SquareRoot, _super);

    function SquareRoot() {
      _ref20 = SquareRoot.__super__.constructor.apply(this, arguments);
      return _ref20;
    }

    SquareRoot.prototype.perform = function(expression_position) {
      var expr, root, value;
      expr = expression_position.expression();
      value = this.value(expr);
      root = Math.sqrt(parseFloat(value));
      if (!isNaN(root)) {
        expr = this.comps.build_expression({
          expression: [
            this.comps.build_number({
              value: "" + root
            })
          ]
        });
        return this.pos.build({
          expression: expr,
          position: expr.id()
        });
      } else {
        expr = expr.clone({
          is_error: true
        });
        return this.pos.build({
          expression: expr,
          position: expr.id()
        });
      }
    };

    return SquareRoot;

  })(ExpressionManipulation);

  class_mixer(SquareRoot);

  Reset = (function(_super) {
    __extends(Reset, _super);

    function Reset() {
      _ref21 = Reset.__super__.constructor.apply(this, arguments);
      return _ref21;
    }

    Reset.prototype.perform = function(expression_position) {
      var empty_expression;
      empty_expression = this.comps.build_expression({
        expression: []
      });
      return this.pos.build({
        expression: empty_expression,
        position: empty_expression.id()
      });
    };

    return Reset;

  })(ExpressionManipulation);

  class_mixer(Reset);

  UpdatePosition = (function(_super) {
    __extends(UpdatePosition, _super);

    function UpdatePosition() {
      _ref22 = UpdatePosition.__super__.constructor.apply(this, arguments);
      return _ref22;
    }

    UpdatePosition.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      UpdatePosition.__super__.initialize.apply(this, arguments);
      this.new_position_element_id = opts.element_id;
      return this.new_position_element_type = opts.type;
    };

    UpdatePosition.prototype.perform = function(expression_position) {
      return expression_position.clone({
        position: this.new_position_element_id,
        type: this.new_position_element_type
      });
    };

    return UpdatePosition;

  })(ExpressionManipulation);

  class_mixer(UpdatePosition);

  SubstituteVariables = (function(_super) {
    __extends(SubstituteVariables, _super);

    function SubstituteVariables() {
      _ref23 = SubstituteVariables.__super__.constructor.apply(this, arguments);
      return _ref23;
    }

    SubstituteVariables.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      SubstituteVariables.__super__.initialize.apply(this, arguments);
      return this.variables = opts.variables;
    };

    SubstituteVariables.prototype.perform = function(expression_position) {
      var exp_pos,
        _this = this;
      exp_pos = expression_position.clone();
      this.traversal.build(exp_pos).each(function(comp) {
        var number;
        if (comp instanceof _this.comps.classes.variable) {
          if (_this.isThisVariable(comp.name())) {
            number = _this.comps.build_number({
              value: _this.variableValue(comp.name())
            });
            return comp.parent().replaceD(comp, number);
          }
        }
      });
      return exp_pos;
    };

    SubstituteVariables.prototype.isThisVariable = function(variable_name) {
      var variable, _i, _len, _ref24;
      _ref24 = this.variables;
      for (_i = 0, _len = _ref24.length; _i < _len; _i++) {
        variable = _ref24[_i];
        if (variable.name === variable_name) {
          return true;
        }
      }
    };

    SubstituteVariables.prototype.variableValue = function(variable_name) {
      var variable, _i, _len, _ref24;
      _ref24 = this.variables;
      for (_i = 0, _len = _ref24.length; _i < _len; _i++) {
        variable = _ref24[_i];
        if (variable.name === variable_name) {
          return variable.value;
        }
      }
    };

    return SubstituteVariables;

  })(ExpressionManipulation);

  class_mixer(SubstituteVariables);

  GetLeftSide = (function(_super) {
    __extends(GetLeftSide, _super);

    function GetLeftSide() {
      _ref24 = GetLeftSide.__super__.constructor.apply(this, arguments);
      return _ref24;
    }

    GetLeftSide.prototype.perform = function(expression_position) {
      var expr;
      expr = expression_position.expression().clone();
      expr.expression.splice(this.indexOfEquals(expr.expression), expr.expression.length);
      return expression_position.clone({
        expression: expr
      });
    };

    GetLeftSide.prototype.indexOfEquals = function(expression) {
      var exp, index;
      for (index in expression) {
        exp = expression[index];
        if (exp instanceof this.comps.classes.equals) {
          return index * 1;
        }
      }
    };

    return GetLeftSide;

  })(ExpressionManipulation);

  class_mixer(GetLeftSide);

  GetRightSide = (function(_super) {
    __extends(GetRightSide, _super);

    function GetRightSide() {
      _ref25 = GetRightSide.__super__.constructor.apply(this, arguments);
      return _ref25;
    }

    GetRightSide.prototype.perform = function(expression_position) {
      var expr;
      expr = expression_position.expression().clone();
      expr.expression.splice(0, this.indexOfEquals(expr.expression) + 1);
      return expression_position.clone({
        expression: expr
      });
    };

    GetRightSide.prototype.indexOfEquals = function(expression) {
      var exp, index;
      for (index in expression) {
        exp = expression[index];
        if (exp instanceof this.comps.classes.equals) {
          return index * 1;
        }
      }
    };

    return GetRightSide;

  })(ExpressionManipulation);

  class_mixer(GetRightSide);

  RemovePointedAt = (function(_super) {
    __extends(RemovePointedAt, _super);

    function RemovePointedAt() {
      _ref26 = RemovePointedAt.__super__.constructor.apply(this, arguments);
      return _ref26;
    }

    RemovePointedAt.prototype.perform = function(expression_position) {
      var result_exp,
        _this = this;
      result_exp = this.M(expression_position).clone().withComponent(expression_position, function(component) {
        return component.withoutLastD();
      }).value();
      return result_exp;
    };

    return RemovePointedAt;

  })(ExpressionManipulation);

  class_mixer(RemovePointedAt);

  exports = {
    calculate: Calculate,
    square: Square,
    append_decimal: AppendDecimal,
    append_number: AppendNumber,
    exponentiate_last: ExponentiateLast,
    append_exponentiation: AppendExponentiation,
    append_multiplication: AppendMultiplication,
    append_addition: AppendAddition,
    append_equals: AppendEquals,
    append_subtraction: AppendSubtraction,
    negate_last: NegateLast,
    append_sub_expression: AppendSubExpression,
    exit_sub_expression: ExitSubExpression,
    append_division: AppendDivision,
    append_pi: AppendPi,
    update_position: UpdatePosition,
    square_root: SquareRoot,
    append_root: AppendRoot,
    append_variable: AppendVariable,
    reset: Reset,
    substitute_variables: SubstituteVariables,
    get_left_side: GetLeftSide,
    get_right_side: GetRightSide,
    append_fraction: AppendFraction,
    append_fn: AppendFn,
    remove_pointed_at: RemovePointedAt
  };

  ExpressionManipulationSource = (function() {
    function ExpressionManipulationSource() {}

    ExpressionManipulationSource.prototype.initialize = function(comps, pos, traversal) {
      var _this = this;
      this.comps = comps;
      this.pos = pos;
      this.traversal = traversal;
      this.utils = {};
      return this.utils.build_expression_position_manipulator = function() {
        return ExpressionPositionManipulator.build(_this.traversal);
      };
    };

    ExpressionManipulationSource.prototype.classes = exports;

    return ExpressionManipulationSource;

  })();

  ttm.class_mixer(ExpressionManipulationSource);

  for (name in exports) {
    klass = exports[name];
    build_klass = (function(name, klass) {
      return function(opts) {
        if (opts == null) {
          opts = {};
        }
        opts.comps = this.comps;
        opts.pos = this.pos;
        opts.traversal = this.traversal;
        return klass.build(opts);
      };
    })(name, klass);
    ExpressionManipulationSource.prototype["build_" + name] = build_klass;
  }

  ttm.lib.math.ExpressionManipulationSource = ExpressionManipulationSource;

}).call(this);

},{}],8:[function(require,module,exports){
(function() {
  var ExpressionPosition, ttm;

  ttm = thinkthroughmath;

  ExpressionPosition = (function() {
    function ExpressionPosition() {}

    ExpressionPosition.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.expr = opts.expression;
      this.pos = opts.position;
      return this.type_val = opts.type;
    };

    ExpressionPosition.prototype.expression = function() {
      return this.expr;
    };

    ExpressionPosition.prototype.position = function() {
      return this.pos;
    };

    ExpressionPosition.prototype.type = function() {
      return this.type_val;
    };

    ExpressionPosition.prototype.isPointedAt = function(expression_component) {
      return ("" + (expression_component.id())) === ("" + (this.position()));
    };

    ExpressionPosition.prototype.clone = function(new_vals) {
      var data, other;
      if (new_vals == null) {
        new_vals = {};
      }
      data = {
        expression: this.expr.clone(),
        position: this.pos,
        type: this.type_val
      };
      other = this.klass.build(_.extend({}, data, new_vals));
      return other;
    };

    ExpressionPosition.buildExpressionPositionAsLast = function(expression) {
      return this.build({
        expression: expression,
        position: expression.id()
      });
    };

    return ExpressionPosition;

  })();

  ttm.lib.math.ExpressionPosition = ttm.class_mixer(ExpressionPosition);

}).call(this);

},{}],9:[function(require,module,exports){
(function() {
  var ExpressionToString, class_mixer, object_refinement, ttm;

  ttm = thinkthroughmath;

  class_mixer = ttm.class_mixer;

  object_refinement = ttm.lib.object_refinement;

  ExpressionToString = (function() {
    function ExpressionToString() {}

    ExpressionToString.prototype.initialize = function(expression_position, expression_contains_cursor) {
      var comps, ref;
      this.expression_position = expression_position;
      this.expression = this.expression_position.expression();
      this.position = this.expression_position.position();
      this.comps = ttm.lib.math.ExpressionComponentSource.build();
      comps = this.comps;
      this.ref = ref = object_refinement.build();
      ref.forDefault({
        toString: function() {
          return "?";
        },
        toHTMLString: function() {
          return "?";
        }
      });
      ref.forType(comps.classes.addition, {
        toString: function() {
          return '+';
        },
        toHTMLString: function() {
          return this.toString();
        }
      });
      ref.forType(comps.classes.exponentiation, {
        base: function(method) {
          if (method == null) {
            method = "toString";
          }
          return ref.refine(this.unrefined().base())[method]({
            include_parentheses_if_single: false
          });
        },
        power: function(method) {
          if (method == null) {
            method = "toString";
          }
          return ref.refine(this.unrefined().power())[method]({
            include_parentheses_if_single: true
          });
        },
        toString: function() {
          return "" + (this.base()) + " ^ " + (this.power());
        },
        toHTMLString: function() {
          return "" + (this.base('toHTMLString')) + " &circ; " + (this.power('toHTMLString'));
        }
      });
      ref.forType(comps.classes.multiplication, {
        toString: function() {
          return "*";
        },
        toHTMLString: function() {
          return "&times;";
        }
      });
      ref.forType(comps.classes.division, {
        toString: function() {
          return "/";
        },
        toHTMLString: function() {
          return "&divide;";
        }
      });
      ref.forType(comps.classes.subtraction, {
        toString: function() {
          return "-";
        },
        toHTMLString: function() {
          return "-";
        }
      });
      ref.forType(comps.classes.expression, {
        toString: function(opts) {
          var ret;
          if (opts == null) {
            opts = {};
          }
          opts = this.optsWithDefaults(opts);
          ret = this.mapconcatWithMethod('toString', opts);
          return this.maybeWrapWithParentheses(ret, opts);
        },
        toHTMLString: function(opts) {
          var ret;
          if (opts == null) {
            opts = {};
          }
          opts = this.optsWithDefaults(opts);
          ret = this.mapconcatWithMethod('toHTMLString', opts);
          return this.maybeWrapWithParentheses(ret, opts);
        },
        mapconcatWithMethod: function(method, opts) {
          return _(this.expression).map(function(it) {
            return ref.refine(it)[method]();
          }).join(' ');
        },
        maybeWrapWithParentheses: function(str, opts) {
          var closing_paren, opening_paren;
          if (!opts.skip_parentheses) {
            opening_paren = opts.skip_parentheses ? "" : !opts.include_parentheses_if_single && this.expression.length === 1 ? "" : "( ";
            closing_paren = expression_contains_cursor.isCursorWithinComponent(this) ? "" : this.expression.length > 1 ? " )" : opts.include_parentheses_if_single && this.expression.length === 1 ? " )" : "";
            return "" + opening_paren + str + closing_paren;
          } else {
            return str;
          }
        },
        decideWrap: function(opts) {},
        optsWithDefaults: function(opts) {
          if (opts == null) {
            opts = {};
          }
          return ttm.defaults(opts, {
            skip_parentheses: false,
            include_parentheses_if_single: true
          });
        }
      });
      ref.forType(comps.classes.blank, {
        toString: function() {
          return "";
        },
        toHTMLString: function() {
          return "";
        }
      });
      ref.forType(comps.classes.number, {
        toString: function() {
          return this.toDisplay();
        },
        toHTMLString: function() {
          return this.toDisplay();
        }
      });
      return ref.forType(comps.classes.pi, {
        toString: function() {
          return 'pi';
        },
        toHTMLString: function() {
          return "<span class='expression-to-string-pi'>&pi;</span>";
        }
      });
    };

    ExpressionToString.prototype.toString = function() {
      return this.ref.refine(this.expression).toString({
        skip_parentheses: true
      });
    };

    ExpressionToString.prototype.toHTMLString = function() {
      return this.ref.refine(this.expression).toHTMLString({
        skip_parentheses: true
      });
    };

    return ExpressionToString;

  })();

  class_mixer(ExpressionToString);

  ExpressionToString.toString = function(expression_position, expression_contains_cursor) {
    return ExpressionToString.build(expression_position, expression_contains_cursor).toString();
  };

  ExpressionToString.toHTMLString = function(expression_position, expression_contains_cursor) {
    return ExpressionToString.build(expression_position, expression_contains_cursor).toHTMLString();
  };

  ttm.lib.math.ExpressionToString = ExpressionToString;

}).call(this);

},{}],10:[function(require,module,exports){
(function() {
  var ExpressionComponentContainsCursor, ExpressionTraversal, ExpressionTraversalBuilder, ttm;

  ttm = thinkthroughmath;

  ExpressionTraversal = (function() {
    function ExpressionTraversal() {}

    ExpressionTraversal.prototype.initialize = function(expr_classes, expression_position) {
      this.expr_classes = expr_classes;
      this.expression_position = expression_position;
      return this.expr = this.expression_position.expression();
    };

    ExpressionTraversal.prototype.each = function(fn, expr) {
      var sub, subexps, _i, _len, _results;
      if (expr == null) {
        expr = this.expr;
      }
      fn(expr);
      subexps = expr.subExpressions();
      _results = [];
      for (_i = 0, _len = subexps.length; _i < _len; _i++) {
        sub = subexps[_i];
        _results.push(this.each(fn, sub));
      }
      return _results;
    };

    ExpressionTraversal.prototype.findForID = function(id) {
      var found;
      found = false;
      this.each(function(exp) {
        if (("" + (exp.id())) === ("" + id)) {
          return found = exp;
        }
      });
      return found;
    };

    ExpressionTraversal.prototype.hasEquals = function() {
      var found_equals,
        _this = this;
      found_equals = false;
      this.each(function(exp) {
        if (exp instanceof _this.expr_classes.equals) {
          return found_equals = true;
        }
      });
      return found_equals;
    };

    ExpressionTraversal.prototype.hasVariableNamed = function(name) {
      var found_equals,
        _this = this;
      found_equals = false;
      this.each(function(exp) {
        if (exp instanceof _this.expr_classes.variable && exp.name() === name) {
          return found_equals = true;
        }
      });
      return found_equals;
    };

    ExpressionTraversal.prototype.buildExpressionComponentContainsCursor = function() {
      return ExpressionComponentContainsCursor.build(this.expression_position, this);
    };

    return ExpressionTraversal;

  })();

  ttm.class_mixer(ExpressionTraversal);

  ExpressionTraversalBuilder = (function() {
    function ExpressionTraversalBuilder() {}

    ExpressionTraversalBuilder.prototype.initialize = function(expression_component_classes) {
      this.expression_component_classes = expression_component_classes;
    };

    ExpressionTraversalBuilder.prototype.build = function(expression_position) {
      this.expression_position = expression_position;
      return ExpressionTraversal.build(this.expression_component_classes, this.expression_position);
    };

    return ExpressionTraversalBuilder;

  })();

  ttm.class_mixer(ExpressionTraversalBuilder);

  ExpressionComponentContainsCursor = (function() {
    function ExpressionComponentContainsCursor() {}

    ExpressionComponentContainsCursor.prototype.initialize = function(expression_position, traversal) {
      this.expression_position = expression_position;
      this.traversal = traversal;
    };

    ExpressionComponentContainsCursor.prototype.isCursorWithinComponent = function(comp) {
      return this.componentIDsWithCursor().indexOf(comp.id()) !== -1;
    };

    ExpressionComponentContainsCursor.prototype.cursorComponent = function() {
      return this.cursorComponent_val || (this.cursorComponent_val = this.traversal.findForID(this.expression_position.position()));
    };

    ExpressionComponentContainsCursor.prototype.componentIDsWithCursor = function() {
      var comp, ids_with_cursor;
      if (!this.componentIDsWithCursor_val) {
        ids_with_cursor = [];
        comp = this.cursorComponent();
        while (comp) {
          ids_with_cursor += comp.id();
          comp = comp.parent();
        }
        this.componentIDsWithCursor_val = ids_with_cursor;
      }
      return this.componentIDsWithCursor_val;
    };

    return ExpressionComponentContainsCursor;

  })();

  ttm.class_mixer(ExpressionComponentContainsCursor);

  ttm.lib.math.ExpressionTraversal = ttm.class_mixer(ExpressionTraversal);

  ttm.lib.math.ExpressionTraversalBuilder = ttm.class_mixer(ExpressionTraversalBuilder);

}).call(this);

},{}],11:[function(require,module,exports){
(function() {
  var Precise, factor, ttm;

  ttm = thinkthroughmath;

  factor = 10000000;

  Precise = (function() {
    function Precise() {}

    Precise.prototype.initialize = function(adjustment_factor) {
      this.adjustment_factor = adjustment_factor != null ? adjustment_factor : factor;
    };

    Precise.prototype.convertInternal = function(val) {
      return parseInt((parseFloat(val) * this.adjustment_factor).toFixed());
    };

    Precise.prototype.convertExternal = function(val) {
      return "" + (val / this.adjustment_factor);
    };

    Precise.prototype.convertExternal2 = function(val) {
      return "" + (val / (this.adjustment_factor * this.adjustment_factor));
    };

    Precise.prototype.sub = function(a, b) {
      return this.wc(a, b, function(a, b) {
        return a - b;
      });
    };

    Precise.prototype.add = function(a, b) {
      return this.wc(a, b, function(a, b) {
        return a + b;
      });
    };

    Precise.prototype.mul = function(a, b) {
      return this.wc2(a, b, function(a, b) {
        return a * b;
      });
    };

    Precise.prototype.div = function(a, b) {
      return this.wc0(a, b, function(a, b) {
        return a / b;
      });
    };

    Precise.prototype.wc = function(a, b, fn) {
      var ac, bc;
      ac = this.convertInternal(a);
      bc = this.convertInternal(b);
      return this.convertExternal(fn(ac, bc));
    };

    Precise.prototype.wc2 = function(a, b, fn) {
      var ac, bc;
      ac = this.convertInternal(a);
      bc = this.convertInternal(b);
      return this.convertExternal2(fn(ac, bc));
    };

    Precise.prototype.wc0 = function(a, b, fn) {
      var ac, bc;
      ac = this.convertInternal(a);
      bc = this.convertInternal(b);
      return "" + (fn(ac, bc));
    };

    return Precise;

  })();

  ttm.lib.math.Precise = ttm.class_mixer(Precise);

}).call(this);

},{}]},{},[1])
;