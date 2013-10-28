;(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};(function() {
  var root, _base;

  root = window || global;

  root.thinkthroughmath || (root.thinkthroughmath = {});

  require("./lib");

  (_base = root.thinkthroughmath).widgets || (_base.widgets = {});

  require("./widgets/ui_elements");

  require("./widgets/math_buttons");

  require("./widgets/calculator");

}).call(this);

},{"./lib":2,"./widgets/calculator":16,"./widgets/math_buttons":17,"./widgets/ui_elements":18}],2:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};(function() {
  var Refinement, RefinementByType, RefinementDeclaration, buildHistoricValue, root, ttm, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = window || global;

  ttm = root.thinkthroughmath || (root.thinkthroughmath = {});

  ttm.lib || (ttm.lib = {});

  _ = require('underscore');

  require('./lib/class_mixer');

  require('./lib/logger');

  require('./lib/polyfill');

  ttm.defaults = function(provided, defaults) {
    return _.extend({}, defaults, provided);
  };

  ttm.logger || (ttm.logger = ttm.Logger.buildProduction({
    stringify_objects: false
  }));

  ttm.AP = function(object) {
    var key, str, value;
    str = "" + object.constructor.name;
    str += "{ ";
    for (key in object) {
      value = object[key];
      str += "" + key + ": " + value;
    }
    str += " }";
    return str;
  };

  ttm.dashboard || (ttm.dashboard = {});

  ttm.decorators || (ttm.decorators = {});

  buildHistoricValue = function() {
    var obj, values;
    values = [];
    obj = {};
    obj.history = function() {
      return values;
    };
    obj.update = function(val) {
      return values.push(val);
    };
    obj.current = function() {
      return values[values.length - 1];
    };
    obj.updatedo = function(fn) {
      return values.push(fn(obj.current()));
    };
    return obj;
  };

  ttm.lib.historic_value = {
    build: buildHistoricValue
  };

  Refinement = (function() {
    function Refinement() {}

    Refinement.prototype.initialize = function() {
      return this.refinements = [];
    };

    Refinement.prototype.forType = function(type, methods) {
      return this.refinements.push(RefinementByType.build(type, methods));
    };

    Refinement.prototype.forDefault = function(methods) {
      return this.default_refinement = RefinementDeclaration.build(methods);
    };

    Refinement.prototype.refine = function(component) {
      var refinement, _i, _len, _ref;
      _ref = this.refinements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        refinement = _ref[_i];
        if (refinement.isApplicable(component)) {
          return refinement.apply(component);
        }
      }
      if (this.default_refinement) {
        return this.default_refinement.apply(component);
      } else {
        return component;
      }
    };

    return Refinement;

  })();

  ttm.class_mixer(Refinement);

  RefinementDeclaration = (function() {
    function RefinementDeclaration() {}

    RefinementDeclaration.prototype.initialize = function(methods) {
      this.methods = methods;
    };

    RefinementDeclaration.prototype.apply = function(subject) {
      var refinement_class, ret;
      refinement_class = function() {};
      refinement_class.prototype = subject;
      ret = new refinement_class;
      _.extend(ret, {
        unrefined: function() {
          return subject;
        }
      }, this.methods);
      return ret;
    };

    return RefinementDeclaration;

  })();

  ttm.class_mixer(RefinementDeclaration);

  RefinementByType = (function(_super) {
    __extends(RefinementByType, _super);

    function RefinementByType() {
      _ref = RefinementByType.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    RefinementByType.prototype.initialize = function(type, methods) {
      this.type = type;
      this.methods = methods;
    };

    RefinementByType.prototype.isApplicable = function(subject) {
      return subject instanceof this.type;
    };

    return RefinementByType;

  })(RefinementDeclaration);

  ttm.class_mixer(RefinementByType);

  ttm.lib.object_refinement = Refinement;

  require('./lib/math');

  _.mixin({
    compactObject: function(o) {
      _.each(o, function(v, k) {
        if (!v) {
          return delete o[k];
        }
      });
      return o;
    }
  });

}).call(this);

},{"./lib/class_mixer":3,"./lib/logger":4,"./lib/math":5,"./lib/polyfill":15,"underscore":19}],3:[function(require,module,exports){
(function() {
  var ttm;

  ttm = thinkthroughmath;

  ttm.ClassMixer = ttm.class_mixer = function(klass) {
    klass.build = function() {
      var it;
      it = new klass;
      it.initialize && it.initialize.apply(it, arguments);
      return it;
    };
    klass.prototype.klass = klass;
    return klass;
  };

}).call(this);

},{}],4:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};(function() {
  var InstrumentedFunctionLogEntry, LogEntry, Logger, LoggerBuilder, LoggerPolicy, ProductionLoggerPolicy, SilentLoggerPolicy, VerboseLoggerPolicy, class_mixer, root, ttm, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require('./class_mixer');

  root = window || global;

  ttm = root.thinkthroughmath;

  class_mixer = ttm.class_mixer;

  LogEntry = (function() {
    function LogEntry() {}

    LogEntry.prototype.initialize = (function(level, args) {
      this.level = level;
      this.args = args;
    });

    LogEntry.prototype.createStrMsg = function(index) {
      var arg, message, _i, _len, _ref;
      message = '';
      _ref = this.args;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        arg = _ref[_i];
        if (typeof arg !== 'string') {
          arg = JSON.stringify(arg);
        }
        message += "" + arg + " ";
      }
      return "" + (this.levelAndEntryIndexString()) + " " + message;
    };

    LogEntry.prototype.createArrMsg = function(index) {
      var arg, current_str, ret, _i, _len, _ref;
      ret = [];
      current_str = this.levelAndEntryIndexString();
      _ref = this.args;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        arg = _ref[_i];
        if (typeof arg === 'string') {
          current_str += " " + arg;
        } else {
          if (current_str.length !== 0) {
            ret.push(current_str);
          }
          current_str = "";
          ret.push(arg);
        }
      }
      if (current_str.length !== 0) {
        ret.push(current_str);
      }
      return ret;
    };

    LogEntry.prototype.levelAndEntryIndexString = function() {
      return "" + this.level + " (#" + this.index + "):";
    };

    LogEntry.prototype.display = function(force_string, index) {
      this.index = index;
      if (force_string) {
        return [this.createStrMsg()];
      } else {
        return this.createArrMsg();
      }
    };

    LogEntry.prototype.match = function(regexp) {
      return this.createStrMsg().match(regexp);
    };

    return LogEntry;

  })();

  class_mixer(LogEntry);

  InstrumentedFunctionLogEntry = (function() {
    function InstrumentedFunctionLogEntry() {}

    InstrumentedFunctionLogEntry.prototype.initialize = (function(args) {
      this.args = args;
    });

    return InstrumentedFunctionLogEntry;

  })();

  class_mixer(InstrumentedFunctionLogEntry);

  Logger = (function() {
    function Logger() {}

    Logger.prototype.initialize = function(opts) {
      if (opts == null) {
        opts = {};
      }
      this.console_log = opts.console_log;
      this.stringify_objects = opts.stringify_objects;
      this.logging_policy = opts.logging_policy;
      this.entries = [];
      return this.unique_id = 0;
    };

    Logger.prototype.add = function(type, args) {
      var entry, entry_index;
      if (args == null) {
        args = [];
      }
      entry = LogEntry.build(type, args);
      if (!this.logging_policy.acceptIncoming(entry)) {
        return;
      }
      this.entries.push(entry);
      entry_index = this.entries.length - 1;
      return this.console_log.apply(null, entry.display(this.stringify_objects, entry_index));
    };

    Logger.prototype.lookup = function(num) {
      return this.entries[num];
    };

    Logger.prototype.error = function() {
      return this.add('error', arguments);
    };

    Logger.prototype.warn = function() {
      return this.add('warn', arguments);
    };

    Logger.prototype.info = function() {
      return this.add('info', arguments);
    };

    Logger.prototype.debug = function() {
      return this.add('debug', arguments);
    };

    Logger.prototype.log = function() {
      return this.add('log', arguments);
    };

    Logger.prototype.getUniqueId = function() {
      return this.unique_id += 1;
    };

    Logger.prototype.instrument = function(opts) {
      var __logger;
      __logger = this;
      return function() {
        var arr, id, retval;
        id = __logger.getUniqueId();
        arr = Array.prototype.slice.call(arguments);
        arr.unshift(this);
        arr.unshift("" + opts.name + " call (id " + id + "): ");
        __logger.add('instrumented', arr);
        retval = opts.fn.apply(this, arguments);
        __logger.add('instrumented', ["" + opts.name + " return (id " + id + "): ", retval]);
        return retval;
      };
    };

    Logger.prototype.logMethodCall = function(name, object, method, args) {
      var id, ret;
      id = this.getUniqueId();
      this.info("method call (id " + id + "): ", name, object, method, args);
      ret = object[method].apply(object, args);
      this.info("method call return (id " + id + "): ", name, method, args, ret);
      return ret;
    };

    return Logger;

  })();

  class_mixer(Logger);

  LoggerPolicy = (function() {
    function LoggerPolicy() {}

    LoggerPolicy.prototype.initialize = function() {
      this.log_entry_types = ['error', 'warn', 'info', 'debug', 'log', 'instrumented'];
      return this.log_entry_display_types = this.typesForLevel('production');
    };

    LoggerPolicy.prototype.typesForLevel = function(level) {
      switch (level) {
        case 'production':
          return ['error', 'warn'];
        case 'firehose':
          return this.log_entry_types;
        default:
          return [];
      }
    };

    LoggerPolicy.prototype.logLevelActive = function(level) {
      return this.log_entry_display_types.indexOf(level) !== -1;
    };

    return LoggerPolicy;

  })();

  class_mixer(LoggerPolicy);

  SilentLoggerPolicy = (function(_super) {
    __extends(SilentLoggerPolicy, _super);

    function SilentLoggerPolicy() {
      _ref = SilentLoggerPolicy.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    SilentLoggerPolicy.prototype.acceptIncoming = function() {
      return false;
    };

    return SilentLoggerPolicy;

  })(LoggerPolicy);

  class_mixer(SilentLoggerPolicy);

  VerboseLoggerPolicy = (function(_super) {
    __extends(VerboseLoggerPolicy, _super);

    function VerboseLoggerPolicy() {
      _ref1 = VerboseLoggerPolicy.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    VerboseLoggerPolicy.prototype.acceptIncoming = function() {
      return true;
    };

    return VerboseLoggerPolicy;

  })(LoggerPolicy);

  class_mixer(VerboseLoggerPolicy);

  ProductionLoggerPolicy = (function(_super) {
    __extends(ProductionLoggerPolicy, _super);

    function ProductionLoggerPolicy() {
      _ref2 = ProductionLoggerPolicy.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ProductionLoggerPolicy.prototype.acceptIncoming = function(entry) {
      return this.logLevelActive(entry.level);
    };

    return ProductionLoggerPolicy;

  })(LoggerPolicy);

  class_mixer(ProductionLoggerPolicy);

  LoggerBuilder = (function() {
    function LoggerBuilder() {}

    LoggerBuilder.prototype.build = function(opts) {
      if (opts == null) {
        opts = {};
      }
      opts = ttm.defaults(opts, {
        console_log: function() {
          if (typeof console !== 'undefined' && console.log) {
            return console.log.apply(console, arguments);
          }
        },
        stringify_objects: true,
        log_level: 'firehose',
        logging_policy: VerboseLoggerPolicy.build()
      });
      return Logger.build(opts);
    };

    LoggerBuilder.prototype.buildSilent = function(opts) {
      var silent;
      if (opts == null) {
        opts = {};
      }
      silent = SilentLoggerPolicy.build();
      return this.build(ttm.defaults(opts, {
        logging_policy: silent
      }));
    };

    LoggerBuilder.prototype.buildVerbose = function(opts) {
      return this.build(opts);
    };

    LoggerBuilder.prototype.buildProduction = function(opts) {
      var prod_policy;
      if (opts == null) {
        opts = {};
      }
      prod_policy = ProductionLoggerPolicy.build();
      return this.build(ttm.defaults(opts, {
        logging_policy: prod_policy
      }));
    };

    return LoggerBuilder;

  })();

  class_mixer(LoggerBuilder);

  thinkthroughmath.Logger = LoggerBuilder.build();

}).call(this);

},{"./class_mixer":3}],5:[function(require,module,exports){
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

},{"./math/build_expression_from_javascript_object":6,"./math/expression_components":7,"./math/expression_equality":8,"./math/expression_evaluation":9,"./math/expression_manipulation":10,"./math/expression_position":11,"./math/expression_to_string":12,"./math/expression_traversal":13,"./math/precise":14}],6:[function(require,module,exports){
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

},{}],7:[function(require,module,exports){
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

},{}],8:[function(require,module,exports){
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

},{}],9:[function(require,module,exports){
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

},{}],10:[function(require,module,exports){
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

},{}],11:[function(require,module,exports){
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

},{}],12:[function(require,module,exports){
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

},{}],13:[function(require,module,exports){
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

},{}],14:[function(require,module,exports){
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

},{}],15:[function(require,module,exports){
if (!Array.prototype.indexOf)
{
  Array.prototype.indexOf = function(elt /*, from*/)
  {
    var len = this.length >>> 0;

    var from = Number(arguments[1]) || 0;
    from = (from < 0)
         ? Math.ceil(from)
         : Math.floor(from);
    if (from < 0)
      from += len;

    for (; from < len; from++)
    {
      if (from in this &&
          this[from] === elt)
        return from;
    }
    return -1;
  };
}

},{}],16:[function(require,module,exports){
(function() {
  var ButtonLayout, Calculator, CalculatorView, calculator_wrapper_class, class_mixer, components, expression_to_string, historic_value, math_buttons_lib, open_widget_dialog, ttm, ui_elements;

  ttm = thinkthroughmath;

  class_mixer = ttm.class_mixer;

  expression_to_string = ttm.lib.math.ExpressionToString;

  historic_value = ttm.lib.historic_value;

  ui_elements = ttm.widgets.UIElements.build();

  math_buttons_lib = ttm.widgets.ButtonBuilder;

  components = ttm.lib.math.ExpressionComponentSource.build();

  calculator_wrapper_class = 'ttm-calculator';

  open_widget_dialog = function(element) {
    if (element.empty()) {
      Calculator.build_widget(element);
    }
    element.dialog({
      dialogClass: "calculator-dialog",
      title: "Calculator"
    });
    element.dialog("open");
    return element.dialog({
      position: {
        my: 'right center',
        at: 'right center',
        of: window
      }
    });
  };

  Calculator = (function() {
    function Calculator() {}

    Calculator.build_widget = function(element) {
      var math;
      math = ttm.lib.math.math_lib.build();
      return Calculator.build(element, math, ttm.logger);
    };

    Calculator.prototype.initialize = function(element, math, logger) {
      this.element = element;
      this.math = math;
      this.logger = logger;
      this.view = CalculatorView.build(this, this.element, this.math);
      this.expression_position = historic_value.build();
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
    };

    Calculator.prototype.displayValue = function() {
      var exp, exp_contains_cursor, exp_pos, val;
      exp_pos = this.expression_position.current();
      exp = exp_pos.expression();
      exp_contains_cursor = this.math.traversal.build(exp_pos).buildExpressionComponentContainsCursor();
      if (!exp.isError()) {
        val = expression_to_string.toHTMLString(exp_pos, exp_contains_cursor);
        if (val.length === 0) {
          return '0';
        } else {
          return val;
        }
      } else {
        return this.errorMsg();
      }
    };

    Calculator.prototype.display = function() {
      var to_disp;
      to_disp = this.displayValue();
      return this.view.display(to_disp);
    };

    Calculator.prototype.errorMsg = function() {
      return "Error";
    };

    Calculator.prototype.updateCurrentExpressionWithCommand = function(command) {
      var new_exp;
      new_exp = command.perform(this.expression_position.current());
      this.reset_on_next_number = false;
      this.expression_position.update(new_exp);
      this.display();
      return this.expression_position.current();
    };

    Calculator.prototype.numberClick = function(button_options) {
      var cmd;
      if (this.reset_on_next_number) {
        this.reset_on_next_number = false;
        this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
      }
      cmd = this.math.commands.build_append_number({
        value: button_options.value
      });
      return this.updateCurrentExpressionWithCommand(cmd);
    };

    Calculator.prototype.exponentClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_exponentiate_last());
    };

    Calculator.prototype.negativeClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_negate_last());
    };

    Calculator.prototype.additionClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_addition());
    };

    Calculator.prototype.multiplicationClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_multiplication());
    };

    Calculator.prototype.divisionClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_division());
    };

    Calculator.prototype.subtractionClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_subtraction());
    };

    Calculator.prototype.decimalClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_decimal());
    };

    Calculator.prototype.clearClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
    };

    Calculator.prototype.equalsClick = function() {
      this.updateCurrentExpressionWithCommand(this.math.commands.build_calculate());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.squareClick = function() {
      this.updateCurrentExpressionWithCommand(this.math.commands.build_square());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.squareRootClick = function() {
      this.updateCurrentExpressionWithCommand(this.math.commands.build_square_root());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.lparenClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_sub_expression());
    };

    Calculator.prototype.rparenClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_exit_sub_expression());
    };

    Calculator.prototype.piClick = function() {
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_pi());
    };

    return Calculator;

  })();

  class_mixer(Calculator);

  ButtonLayout = (function() {
    function ButtonLayout() {}

    ButtonLayout.prototype.initialize = (function(components) {
      this.components = components;
    });

    ButtonLayout.prototype.render = function(element) {
      this.element = element;
      this.render_components(["square", "square_root", "exponent", "clear"]);
      this.render_components(["pi", "lparen", "rparen", "division"]);
      this.render_numbers([7, 8, 9]);
      this.render_component("multiplication");
      this.render_numbers([4, 5, 6]);
      this.render_component("subtraction");
      this.render_numbers([1, 2, 3]);
      this.render_component("addition");
      this.render_numbers([0]);
      return this.render_components(["decimal", "negative", "equals"]);
    };

    ButtonLayout.prototype.render_numbers = function(nums) {
      var num, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = nums.length; _i < _len; _i++) {
        num = nums[_i];
        _results.push(this.components.numbers[num].render({
          element: this.element
        }));
      }
      return _results;
    };

    ButtonLayout.prototype.render_component = function(comp) {
      return this.components[comp].render({
        element: this.element
      });
    };

    ButtonLayout.prototype.render_components = function(components) {
      var comp, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        comp = components[_i];
        _results.push(this.render_component(comp));
      }
      return _results;
    };

    return ButtonLayout;

  })();

  class_mixer(ButtonLayout);

  CalculatorView = (function() {
    function CalculatorView() {}

    CalculatorView.prototype.initialize = function(calc, element, math) {
      var buttons, math_button_builder,
        _this = this;
      this.calc = calc;
      this.element = element;
      this.math = math;
      math_button_builder = math_buttons_lib.build({
        element: this.element,
        ui_elements: ui_elements
      });
      buttons = {};
      buttons.numbers = math_button_builder.base10Digits({
        click: function(val) {
          return _this.calc.numberClick(val);
        }
      });
      buttons.negative = math_button_builder.negative({
        click: function() {
          return _this.calc.negativeClick();
        }
      });
      buttons.decimal = math_button_builder.decimal({
        click: function() {
          return _this.calc.decimalClick();
        }
      });
      buttons.addition = math_button_builder.addition({
        click: function() {
          return _this.calc.additionClick();
        }
      });
      buttons.multiplication = math_button_builder.multiplication({
        click: function() {
          return _this.calc.multiplicationClick();
        }
      });
      buttons.division = math_button_builder.division({
        click: function() {
          return _this.calc.divisionClick();
        }
      });
      buttons.subtraction = math_button_builder.subtraction({
        click: function() {
          return _this.calc.subtractionClick();
        }
      });
      buttons.equals = math_button_builder.equals({
        click: function() {
          return _this.calc.equalsClick();
        }
      });
      buttons.clear = math_button_builder.clear({
        click: function() {
          return _this.calc.clearClick();
        }
      });
      buttons.square = math_button_builder.square({
        click: function() {
          return _this.calc.squareClick();
        }
      });
      buttons.square_root = math_button_builder.root({
        click: function() {
          return _this.calc.squareRootClick();
        }
      });
      buttons.exponent = math_button_builder.caret({
        click: function() {
          return _this.calc.exponentClick();
        }
      });
      buttons.lparen = math_button_builder.lparen({
        click: function() {
          return _this.calc.lparenClick();
        }
      });
      buttons.rparen = math_button_builder.rparen({
        click: function() {
          return _this.calc.rparenClick();
        }
      });
      buttons.pi = math_button_builder.pi({
        click: function() {
          return _this.calc.piClick();
        }
      });
      this.layout = ButtonLayout.build(buttons);
      return this.render();
    };

    CalculatorView.prototype.display = function(content) {
      var disp;
      disp = this.element.find("figure.calculator-display");
      disp.html(content);
      return disp.scrollLeft(9999999);
    };

    CalculatorView.prototype.render = function() {
      var calc_div;
      this.element.append("<div class='" + calculator_wrapper_class + "'></div>");
      calc_div = this.element.find("div." + calculator_wrapper_class);
      calc_div.append("<figure class='calculator-display'>0</figure>");
      return this.layout.render(calc_div);
    };

    return CalculatorView;

  })();

  class_mixer(CalculatorView);

  Calculator.openWidgetDialog = open_widget_dialog;

  ttm.widgets.Calculator = Calculator;

}).call(this);

},{}],17:[function(require,module,exports){
(function() {
  var ButtonBuilder, math_var, ttm;

  ttm = thinkthroughmath;

  math_var = function(name) {
    return "<span class='math-variable'>" + name + "</span>";
  };

  ButtonBuilder = (function() {
    function ButtonBuilder() {}

    ButtonBuilder.prototype.initialize = function(opts) {
      this.opts = opts != null ? opts : {};
      return this.ui_elements = this.opts.ui_elements;
    };

    ButtonBuilder.prototype.base10Digits = function(opts) {
      var num, _i, _results,
        _this = this;
      if (opts == null) {
        opts = {};
      }
      _results = [];
      for (num = _i = 0; _i <= 9; num = ++_i) {
        _results.push((function(num) {
          return _this.button({
            value: "" + num,
            "class": 'math-button number-specifier number'
          }, opts);
        })(num));
      }
      return _results;
    };

    ButtonBuilder.prototype.caret = function(opts) {
      return this.button({
        value: '^',
        label: '&circ;',
        "class": 'math-button other caret'
      }, opts);
    };

    ButtonBuilder.prototype.negative = function(opts) {
      return this.button({
        value: 'negative',
        label: '(&ndash;)',
        "class": 'math-button number-specifier negative'
      }, opts);
    };

    ButtonBuilder.prototype.negative_slash_positive = function(opts) {
      return this.button({
        value: '-/+',
        label: "&ndash;/+",
        "class": 'math-button number-specifier negative-slash-positive'
      }, opts);
    };

    ButtonBuilder.prototype.decimal = function(opts) {
      return this.button({
        value: '.',
        "class": 'math-button number-specifier decimal'
      }, opts);
    };

    ButtonBuilder.prototype.addition = function(opts) {
      return this.button({
        value: '+',
        "class": 'math-button operation'
      }, opts);
    };

    ButtonBuilder.prototype.multiplication = function(opts) {
      return this.button({
        value: '*',
        label: '&times;',
        "class": 'math-button operation'
      }, opts);
    };

    ButtonBuilder.prototype.division = function(opts) {
      return this.button({
        value: '/',
        label: '&divide;',
        "class": 'math-button operation'
      }, opts);
    };

    ButtonBuilder.prototype.subtraction = function(opts) {
      return this.button({
        value: '-',
        label: '&ndash;',
        "class": 'math-button operation'
      }, opts);
    };

    ButtonBuilder.prototype.subtraction = function(opts) {
      return this.button({
        value: '-',
        label: '&ndash;',
        "class": 'math-button operation'
      }, opts);
    };

    ButtonBuilder.prototype.equals = function(opts) {
      return this.button({
        value: '=',
        "class": 'math-button operation equal'
      }, opts);
    };

    ButtonBuilder.prototype.clear = function(opts) {
      return this.button({
        value: 'clear',
        "class": 'math-button other clear'
      }, opts);
    };

    ButtonBuilder.prototype.del = function(opts) {
      return this.button({
        value: 'del',
        "class": 'math-button other del'
      }, opts);
    };

    ButtonBuilder.prototype.square = function(opts) {
      return this.button({
        value: 'square',
        label: "" + (math_var('x')) + "<sup>2</sup>",
        "class": 'math-button other square'
      }, opts);
    };

    ButtonBuilder.prototype.exponent = function(opts) {
      var base, power;
      base = opts.base || math_var('x');
      power = opts.power || math_var('y');
      return this.button({
        value: 'exponent',
        label: "" + base + "<sup>" + power + "</sup>",
        "class": 'math-button other exponent'
      }, opts);
    };

    ButtonBuilder.prototype.root = function(opts) {
      var degree, radicand;
      degree = opts.degree ? "<div class='degree'>" + opts.degree + "</div>" : "";
      radicand = opts.radicand ? "<div class='radicand'>" + opts.radicand + "</div>" : "<div class='radicand'>" + (math_var('x')) + "</div>";
      return this.button({
        value: 'root',
        label: "" + degree + "\n" + radicand + "\n<div class='radix'>&radic;</div>\n<div class='vinculum'>&#8212;</div>",
        "class": 'math-button other root'
      }, opts);
    };

    ButtonBuilder.prototype.fraction = function(opts) {
      return this.button({
        value: 'fraction',
        label: "<div class='numerator'>a</div>\n<div class='vinculum'>&#8212;</div>\n<div class='denominator'>b</div>",
        "class": 'math-button other fraction'
      }, opts);
    };

    ButtonBuilder.prototype.lparen = function(opts) {
      return this.button({
        value: '(',
        "class": 'math-button parentheses other'
      }, opts);
    };

    ButtonBuilder.prototype.rparen = function(opts) {
      return this.button({
        value: ')',
        "class": 'math-button parentheses other'
      }, opts);
    };

    ButtonBuilder.prototype.pi = function(opts) {
      return this.button({
        value: 'pi',
        label: '&pi;',
        "class": 'math-button pi other'
      }, opts);
    };

    ButtonBuilder.prototype.variables = function(opts) {
      var v, variables;
      variables = (function() {
        var _i, _len, _ref, _results,
          _this = this;
        _ref = opts.variables;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          _results.push((function(v) {
            return _this.button({
              value: "" + v.name,
              "class": 'math-button variable other',
              variable: v
            }, opts);
          })(v));
        }
        return _results;
      }).call(this);
      return variables;
    };

    ButtonBuilder.prototype.fn = function(opts) {
      var value;
      value = opts.name ? "function[" + opts.name + "]" : "function";
      return this.button({
        value: value,
        label: '&fnof;',
        "class": 'math-button other function'
      }, opts);
    };

    ButtonBuilder.prototype.button = function(type_opts, opts) {
      return this.ui_elements.button_builder.build(_.extend({}, type_opts, this.opts, opts || {}));
    };

    return ButtonBuilder;

  })();

  ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder);

}).call(this);

},{}],18:[function(require,module,exports){
(function() {
  var Button, MathDisplay, UIElements, ttm;

  ttm = thinkthroughmath;

  Button = (function() {
    function Button() {}

    Button.prototype.initialize = function(opts) {
      this.opts = opts != null ? opts : {};
    };

    Button.prototype.render = function(opts) {
      var button;
      if (opts == null) {
        opts = {};
      }
      opts = _.extend({}, this.opts, opts);
      button = $("<button class='" + opts["class"] + "' value='" + opts.value + "'>" + (opts.label || opts.value) + "</button>");
      button.on("click", function() {
        return opts.click && opts.click(opts);
      });
      return opts.element.append(button);
    };

    return Button;

  })();

  ttm.class_mixer(Button);

  MathDisplay = (function() {
    function MathDisplay() {}

    MathDisplay.prototype.initialize = function(opts) {
      this.opts = opts != null ? opts : {};
    };

    MathDisplay.prototype.render = function(opts) {
      if (opts == null) {
        opts = {};
      }
      opts = _.extend({}, this.opts, opts);
      this.figure = $("<figure class='math-display " + opts["class"] + "'>" + (opts["default"] || '0') + "</figure>");
      opts.element.append(this.figure);
      return this.figure;
    };

    MathDisplay.prototype.update = function(value) {
      return this.figure.html(value);
    };

    return MathDisplay;

  })();

  ttm.class_mixer(MathDisplay);

  UIElements = (function() {
    function UIElements() {}

    UIElements.prototype.button_builder = Button;

    UIElements.prototype.math_display_builder = MathDisplay;

    return UIElements;

  })();

  ttm.widgets.UIElements = ttm.class_mixer(UIElements);

}).call(this);

},{}],19:[function(require,module,exports){
//     Underscore.js 1.5.2
//     http://underscorejs.org
//     (c) 2009-2013 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
//     Underscore may be freely distributed under the MIT license.

(function() {

  // Baseline setup
  // --------------

  // Establish the root object, `window` in the browser, or `exports` on the server.
  var root = this;

  // Save the previous value of the `_` variable.
  var previousUnderscore = root._;

  // Establish the object that gets returned to break out of a loop iteration.
  var breaker = {};

  // Save bytes in the minified (but not gzipped) version:
  var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

  // Create quick reference variables for speed access to core prototypes.
  var
    push             = ArrayProto.push,
    slice            = ArrayProto.slice,
    concat           = ArrayProto.concat,
    toString         = ObjProto.toString,
    hasOwnProperty   = ObjProto.hasOwnProperty;

  // All **ECMAScript 5** native function implementations that we hope to use
  // are declared here.
  var
    nativeForEach      = ArrayProto.forEach,
    nativeMap          = ArrayProto.map,
    nativeReduce       = ArrayProto.reduce,
    nativeReduceRight  = ArrayProto.reduceRight,
    nativeFilter       = ArrayProto.filter,
    nativeEvery        = ArrayProto.every,
    nativeSome         = ArrayProto.some,
    nativeIndexOf      = ArrayProto.indexOf,
    nativeLastIndexOf  = ArrayProto.lastIndexOf,
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind;

  // Create a safe reference to the Underscore object for use below.
  var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };

  // Export the Underscore object for **Node.js**, with
  // backwards-compatibility for the old `require()` API. If we're in
  // the browser, add `_` as a global object via a string identifier,
  // for Closure Compiler "advanced" mode.
  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else {
    root._ = _;
  }

  // Current version.
  _.VERSION = '1.5.2';

  // Collection Functions
  // --------------------

  // The cornerstone, an `each` implementation, aka `forEach`.
  // Handles objects with the built-in `forEach`, arrays, and raw objects.
  // Delegates to **ECMAScript 5**'s native `forEach` if available.
  var each = _.each = _.forEach = function(obj, iterator, context) {
    if (obj == null) return;
    if (nativeForEach && obj.forEach === nativeForEach) {
      obj.forEach(iterator, context);
    } else if (obj.length === +obj.length) {
      for (var i = 0, length = obj.length; i < length; i++) {
        if (iterator.call(context, obj[i], i, obj) === breaker) return;
      }
    } else {
      var keys = _.keys(obj);
      for (var i = 0, length = keys.length; i < length; i++) {
        if (iterator.call(context, obj[keys[i]], keys[i], obj) === breaker) return;
      }
    }
  };

  // Return the results of applying the iterator to each element.
  // Delegates to **ECMAScript 5**'s native `map` if available.
  _.map = _.collect = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
    each(obj, function(value, index, list) {
      results.push(iterator.call(context, value, index, list));
    });
    return results;
  };

  var reduceError = 'Reduce of empty array with no initial value';

  // **Reduce** builds up a single result from a list of values, aka `inject`,
  // or `foldl`. Delegates to **ECMAScript 5**'s native `reduce` if available.
  _.reduce = _.foldl = _.inject = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduce(iterator, memo) : obj.reduce(iterator);
    }
    each(obj, function(value, index, list) {
      if (!initial) {
        memo = value;
        initial = true;
      } else {
        memo = iterator.call(context, memo, value, index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // The right-associative version of reduce, also known as `foldr`.
  // Delegates to **ECMAScript 5**'s native `reduceRight` if available.
  _.reduceRight = _.foldr = function(obj, iterator, memo, context) {
    var initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduceRight && obj.reduceRight === nativeReduceRight) {
      if (context) iterator = _.bind(iterator, context);
      return initial ? obj.reduceRight(iterator, memo) : obj.reduceRight(iterator);
    }
    var length = obj.length;
    if (length !== +length) {
      var keys = _.keys(obj);
      length = keys.length;
    }
    each(obj, function(value, index, list) {
      index = keys ? keys[--length] : --length;
      if (!initial) {
        memo = obj[index];
        initial = true;
      } else {
        memo = iterator.call(context, memo, obj[index], index, list);
      }
    });
    if (!initial) throw new TypeError(reduceError);
    return memo;
  };

  // Return the first value which passes a truth test. Aliased as `detect`.
  _.find = _.detect = function(obj, iterator, context) {
    var result;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  // Return all the elements that pass a truth test.
  // Delegates to **ECMAScript 5**'s native `filter` if available.
  // Aliased as `select`.
  _.filter = _.select = function(obj, iterator, context) {
    var results = [];
    if (obj == null) return results;
    if (nativeFilter && obj.filter === nativeFilter) return obj.filter(iterator, context);
    each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) results.push(value);
    });
    return results;
  };

  // Return all the elements for which a truth test fails.
  _.reject = function(obj, iterator, context) {
    return _.filter(obj, function(value, index, list) {
      return !iterator.call(context, value, index, list);
    }, context);
  };

  // Determine whether all of the elements match a truth test.
  // Delegates to **ECMAScript 5**'s native `every` if available.
  // Aliased as `all`.
  _.every = _.all = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = true;
    if (obj == null) return result;
    if (nativeEvery && obj.every === nativeEvery) return obj.every(iterator, context);
    each(obj, function(value, index, list) {
      if (!(result = result && iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if at least one element in the object matches a truth test.
  // Delegates to **ECMAScript 5**'s native `some` if available.
  // Aliased as `any`.
  var any = _.some = _.any = function(obj, iterator, context) {
    iterator || (iterator = _.identity);
    var result = false;
    if (obj == null) return result;
    if (nativeSome && obj.some === nativeSome) return obj.some(iterator, context);
    each(obj, function(value, index, list) {
      if (result || (result = iterator.call(context, value, index, list))) return breaker;
    });
    return !!result;
  };

  // Determine if the array or object contains a given value (using `===`).
  // Aliased as `include`.
  _.contains = _.include = function(obj, target) {
    if (obj == null) return false;
    if (nativeIndexOf && obj.indexOf === nativeIndexOf) return obj.indexOf(target) != -1;
    return any(obj, function(value) {
      return value === target;
    });
  };

  // Invoke a method (with arguments) on every item in a collection.
  _.invoke = function(obj, method) {
    var args = slice.call(arguments, 2);
    var isFunc = _.isFunction(method);
    return _.map(obj, function(value) {
      return (isFunc ? method : value[method]).apply(value, args);
    });
  };

  // Convenience version of a common use case of `map`: fetching a property.
  _.pluck = function(obj, key) {
    return _.map(obj, function(value){ return value[key]; });
  };

  // Convenience version of a common use case of `filter`: selecting only objects
  // containing specific `key:value` pairs.
  _.where = function(obj, attrs, first) {
    if (_.isEmpty(attrs)) return first ? void 0 : [];
    return _[first ? 'find' : 'filter'](obj, function(value) {
      for (var key in attrs) {
        if (attrs[key] !== value[key]) return false;
      }
      return true;
    });
  };

  // Convenience version of a common use case of `find`: getting the first object
  // containing specific `key:value` pairs.
  _.findWhere = function(obj, attrs) {
    return _.where(obj, attrs, true);
  };

  // Return the maximum element or (element-based computation).
  // Can't optimize arrays of integers longer than 65,535 elements.
  // See [WebKit Bug 80797](https://bugs.webkit.org/show_bug.cgi?id=80797)
  _.max = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.max.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return -Infinity;
    var result = {computed : -Infinity, value: -Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed > result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Return the minimum element (or element-based computation).
  _.min = function(obj, iterator, context) {
    if (!iterator && _.isArray(obj) && obj[0] === +obj[0] && obj.length < 65535) {
      return Math.min.apply(Math, obj);
    }
    if (!iterator && _.isEmpty(obj)) return Infinity;
    var result = {computed : Infinity, value: Infinity};
    each(obj, function(value, index, list) {
      var computed = iterator ? iterator.call(context, value, index, list) : value;
      computed < result.computed && (result = {value : value, computed : computed});
    });
    return result.value;
  };

  // Shuffle an array, using the modern version of the 
  // [Fisher-Yates shuffle](http://en.wikipedia.org/wiki/Fisher–Yates_shuffle).
  _.shuffle = function(obj) {
    var rand;
    var index = 0;
    var shuffled = [];
    each(obj, function(value) {
      rand = _.random(index++);
      shuffled[index - 1] = shuffled[rand];
      shuffled[rand] = value;
    });
    return shuffled;
  };

  // Sample **n** random values from an array.
  // If **n** is not specified, returns a single random element from the array.
  // The internal `guard` argument allows it to work with `map`.
  _.sample = function(obj, n, guard) {
    if (arguments.length < 2 || guard) {
      return obj[_.random(obj.length - 1)];
    }
    return _.shuffle(obj).slice(0, Math.max(0, n));
  };

  // An internal function to generate lookup iterators.
  var lookupIterator = function(value) {
    return _.isFunction(value) ? value : function(obj){ return obj[value]; };
  };

  // Sort the object's values by a criterion produced by an iterator.
  _.sortBy = function(obj, value, context) {
    var iterator = lookupIterator(value);
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value: value,
        index: index,
        criteria: iterator.call(context, value, index, list)
      };
    }).sort(function(left, right) {
      var a = left.criteria;
      var b = right.criteria;
      if (a !== b) {
        if (a > b || a === void 0) return 1;
        if (a < b || b === void 0) return -1;
      }
      return left.index - right.index;
    }), 'value');
  };

  // An internal function used for aggregate "group by" operations.
  var group = function(behavior) {
    return function(obj, value, context) {
      var result = {};
      var iterator = value == null ? _.identity : lookupIterator(value);
      each(obj, function(value, index) {
        var key = iterator.call(context, value, index, obj);
        behavior(result, key, value);
      });
      return result;
    };
  };

  // Groups the object's values by a criterion. Pass either a string attribute
  // to group by, or a function that returns the criterion.
  _.groupBy = group(function(result, key, value) {
    (_.has(result, key) ? result[key] : (result[key] = [])).push(value);
  });

  // Indexes the object's values by a criterion, similar to `groupBy`, but for
  // when you know that your index values will be unique.
  _.indexBy = group(function(result, key, value) {
    result[key] = value;
  });

  // Counts instances of an object that group by a certain criterion. Pass
  // either a string attribute to count by, or a function that returns the
  // criterion.
  _.countBy = group(function(result, key) {
    _.has(result, key) ? result[key]++ : result[key] = 1;
  });

  // Use a comparator function to figure out the smallest index at which
  // an object should be inserted so as to maintain order. Uses binary search.
  _.sortedIndex = function(array, obj, iterator, context) {
    iterator = iterator == null ? _.identity : lookupIterator(iterator);
    var value = iterator.call(context, obj);
    var low = 0, high = array.length;
    while (low < high) {
      var mid = (low + high) >>> 1;
      iterator.call(context, array[mid]) < value ? low = mid + 1 : high = mid;
    }
    return low;
  };

  // Safely create a real, live array from anything iterable.
  _.toArray = function(obj) {
    if (!obj) return [];
    if (_.isArray(obj)) return slice.call(obj);
    if (obj.length === +obj.length) return _.map(obj, _.identity);
    return _.values(obj);
  };

  // Return the number of elements in an object.
  _.size = function(obj) {
    if (obj == null) return 0;
    return (obj.length === +obj.length) ? obj.length : _.keys(obj).length;
  };

  // Array Functions
  // ---------------

  // Get the first element of an array. Passing **n** will return the first N
  // values in the array. Aliased as `head` and `take`. The **guard** check
  // allows it to work with `_.map`.
  _.first = _.head = _.take = function(array, n, guard) {
    if (array == null) return void 0;
    return (n == null) || guard ? array[0] : slice.call(array, 0, n);
  };

  // Returns everything but the last entry of the array. Especially useful on
  // the arguments object. Passing **n** will return all the values in
  // the array, excluding the last N. The **guard** check allows it to work with
  // `_.map`.
  _.initial = function(array, n, guard) {
    return slice.call(array, 0, array.length - ((n == null) || guard ? 1 : n));
  };

  // Get the last element of an array. Passing **n** will return the last N
  // values in the array. The **guard** check allows it to work with `_.map`.
  _.last = function(array, n, guard) {
    if (array == null) return void 0;
    if ((n == null) || guard) {
      return array[array.length - 1];
    } else {
      return slice.call(array, Math.max(array.length - n, 0));
    }
  };

  // Returns everything but the first entry of the array. Aliased as `tail` and `drop`.
  // Especially useful on the arguments object. Passing an **n** will return
  // the rest N values in the array. The **guard**
  // check allows it to work with `_.map`.
  _.rest = _.tail = _.drop = function(array, n, guard) {
    return slice.call(array, (n == null) || guard ? 1 : n);
  };

  // Trim out all falsy values from an array.
  _.compact = function(array) {
    return _.filter(array, _.identity);
  };

  // Internal implementation of a recursive `flatten` function.
  var flatten = function(input, shallow, output) {
    if (shallow && _.every(input, _.isArray)) {
      return concat.apply(output, input);
    }
    each(input, function(value) {
      if (_.isArray(value) || _.isArguments(value)) {
        shallow ? push.apply(output, value) : flatten(value, shallow, output);
      } else {
        output.push(value);
      }
    });
    return output;
  };

  // Flatten out an array, either recursively (by default), or just one level.
  _.flatten = function(array, shallow) {
    return flatten(array, shallow, []);
  };

  // Return a version of the array that does not contain the specified value(s).
  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  // Produce a duplicate-free version of the array. If the array has already
  // been sorted, you have the option of using a faster algorithm.
  // Aliased as `unique`.
  _.uniq = _.unique = function(array, isSorted, iterator, context) {
    if (_.isFunction(isSorted)) {
      context = iterator;
      iterator = isSorted;
      isSorted = false;
    }
    var initial = iterator ? _.map(array, iterator, context) : array;
    var results = [];
    var seen = [];
    each(initial, function(value, index) {
      if (isSorted ? (!index || seen[seen.length - 1] !== value) : !_.contains(seen, value)) {
        seen.push(value);
        results.push(array[index]);
      }
    });
    return results;
  };

  // Produce an array that contains the union: each distinct element from all of
  // the passed-in arrays.
  _.union = function() {
    return _.uniq(_.flatten(arguments, true));
  };

  // Produce an array that contains every item shared between all the
  // passed-in arrays.
  _.intersection = function(array) {
    var rest = slice.call(arguments, 1);
    return _.filter(_.uniq(array), function(item) {
      return _.every(rest, function(other) {
        return _.indexOf(other, item) >= 0;
      });
    });
  };

  // Take the difference between one array and a number of other arrays.
  // Only the elements present in just the first array will remain.
  _.difference = function(array) {
    var rest = concat.apply(ArrayProto, slice.call(arguments, 1));
    return _.filter(array, function(value){ return !_.contains(rest, value); });
  };

  // Zip together multiple lists into a single array -- elements that share
  // an index go together.
  _.zip = function() {
    var length = _.max(_.pluck(arguments, "length").concat(0));
    var results = new Array(length);
    for (var i = 0; i < length; i++) {
      results[i] = _.pluck(arguments, '' + i);
    }
    return results;
  };

  // Converts lists into objects. Pass either a single array of `[key, value]`
  // pairs, or two parallel arrays of the same length -- one of keys, and one of
  // the corresponding values.
  _.object = function(list, values) {
    if (list == null) return {};
    var result = {};
    for (var i = 0, length = list.length; i < length; i++) {
      if (values) {
        result[list[i]] = values[i];
      } else {
        result[list[i][0]] = list[i][1];
      }
    }
    return result;
  };

  // If the browser doesn't supply us with indexOf (I'm looking at you, **MSIE**),
  // we need this function. Return the position of the first occurrence of an
  // item in an array, or -1 if the item is not included in the array.
  // Delegates to **ECMAScript 5**'s native `indexOf` if available.
  // If the array is large and already in sort order, pass `true`
  // for **isSorted** to use binary search.
  _.indexOf = function(array, item, isSorted) {
    if (array == null) return -1;
    var i = 0, length = array.length;
    if (isSorted) {
      if (typeof isSorted == 'number') {
        i = (isSorted < 0 ? Math.max(0, length + isSorted) : isSorted);
      } else {
        i = _.sortedIndex(array, item);
        return array[i] === item ? i : -1;
      }
    }
    if (nativeIndexOf && array.indexOf === nativeIndexOf) return array.indexOf(item, isSorted);
    for (; i < length; i++) if (array[i] === item) return i;
    return -1;
  };

  // Delegates to **ECMAScript 5**'s native `lastIndexOf` if available.
  _.lastIndexOf = function(array, item, from) {
    if (array == null) return -1;
    var hasIndex = from != null;
    if (nativeLastIndexOf && array.lastIndexOf === nativeLastIndexOf) {
      return hasIndex ? array.lastIndexOf(item, from) : array.lastIndexOf(item);
    }
    var i = (hasIndex ? from : array.length);
    while (i--) if (array[i] === item) return i;
    return -1;
  };

  // Generate an integer Array containing an arithmetic progression. A port of
  // the native Python `range()` function. See
  // [the Python documentation](http://docs.python.org/library/functions.html#range).
  _.range = function(start, stop, step) {
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }
    step = arguments[2] || 1;

    var length = Math.max(Math.ceil((stop - start) / step), 0);
    var idx = 0;
    var range = new Array(length);

    while(idx < length) {
      range[idx++] = start;
      start += step;
    }

    return range;
  };

  // Function (ahem) Functions
  // ------------------

  // Reusable constructor function for prototype setting.
  var ctor = function(){};

  // Create a function bound to a given object (assigning `this`, and arguments,
  // optionally). Delegates to **ECMAScript 5**'s native `Function.bind` if
  // available.
  _.bind = function(func, context) {
    var args, bound;
    if (nativeBind && func.bind === nativeBind) return nativeBind.apply(func, slice.call(arguments, 1));
    if (!_.isFunction(func)) throw new TypeError;
    args = slice.call(arguments, 2);
    return bound = function() {
      if (!(this instanceof bound)) return func.apply(context, args.concat(slice.call(arguments)));
      ctor.prototype = func.prototype;
      var self = new ctor;
      ctor.prototype = null;
      var result = func.apply(self, args.concat(slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  };

  // Partially apply a function by creating a version that has had some of its
  // arguments pre-filled, without changing its dynamic `this` context.
  _.partial = function(func) {
    var args = slice.call(arguments, 1);
    return function() {
      return func.apply(this, args.concat(slice.call(arguments)));
    };
  };

  // Bind all of an object's methods to that object. Useful for ensuring that
  // all callbacks defined on an object belong to it.
  _.bindAll = function(obj) {
    var funcs = slice.call(arguments, 1);
    if (funcs.length === 0) throw new Error("bindAll must be passed function names");
    each(funcs, function(f) { obj[f] = _.bind(obj[f], obj); });
    return obj;
  };

  // Memoize an expensive function by storing its results.
  _.memoize = function(func, hasher) {
    var memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key = hasher.apply(this, arguments);
      return _.has(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
    };
  };

  // Delays a function for the given number of milliseconds, and then calls
  // it with the arguments supplied.
  _.delay = function(func, wait) {
    var args = slice.call(arguments, 2);
    return setTimeout(function(){ return func.apply(null, args); }, wait);
  };

  // Defers a function, scheduling it to run after the current call stack has
  // cleared.
  _.defer = function(func) {
    return _.delay.apply(_, [func, 1].concat(slice.call(arguments, 1)));
  };

  // Returns a function, that, when invoked, will only be triggered at most once
  // during a given window of time. Normally, the throttled function will run
  // as much as it can, without ever going more than once per `wait` duration;
  // but if you'd like to disable the execution on the leading edge, pass
  // `{leading: false}`. To disable execution on the trailing edge, ditto.
  _.throttle = function(func, wait, options) {
    var context, args, result;
    var timeout = null;
    var previous = 0;
    options || (options = {});
    var later = function() {
      previous = options.leading === false ? 0 : new Date;
      timeout = null;
      result = func.apply(context, args);
    };
    return function() {
      var now = new Date;
      if (!previous && options.leading === false) previous = now;
      var remaining = wait - (now - previous);
      context = this;
      args = arguments;
      if (remaining <= 0) {
        clearTimeout(timeout);
        timeout = null;
        previous = now;
        result = func.apply(context, args);
      } else if (!timeout && options.trailing !== false) {
        timeout = setTimeout(later, remaining);
      }
      return result;
    };
  };

  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds. If `immediate` is passed, trigger the function on the
  // leading edge, instead of the trailing.
  _.debounce = function(func, wait, immediate) {
    var timeout, args, context, timestamp, result;
    return function() {
      context = this;
      args = arguments;
      timestamp = new Date();
      var later = function() {
        var last = (new Date()) - timestamp;
        if (last < wait) {
          timeout = setTimeout(later, wait - last);
        } else {
          timeout = null;
          if (!immediate) result = func.apply(context, args);
        }
      };
      var callNow = immediate && !timeout;
      if (!timeout) {
        timeout = setTimeout(later, wait);
      }
      if (callNow) result = func.apply(context, args);
      return result;
    };
  };

  // Returns a function that will be executed at most one time, no matter how
  // often you call it. Useful for lazy initialization.
  _.once = function(func) {
    var ran = false, memo;
    return function() {
      if (ran) return memo;
      ran = true;
      memo = func.apply(this, arguments);
      func = null;
      return memo;
    };
  };

  // Returns the first function passed as an argument to the second,
  // allowing you to adjust arguments, run code before and after, and
  // conditionally execute the original function.
  _.wrap = function(func, wrapper) {
    return function() {
      var args = [func];
      push.apply(args, arguments);
      return wrapper.apply(this, args);
    };
  };

  // Returns a function that is the composition of a list of functions, each
  // consuming the return value of the function that follows.
  _.compose = function() {
    var funcs = arguments;
    return function() {
      var args = arguments;
      for (var i = funcs.length - 1; i >= 0; i--) {
        args = [funcs[i].apply(this, args)];
      }
      return args[0];
    };
  };

  // Returns a function that will only be executed after being called N times.
  _.after = function(times, func) {
    return function() {
      if (--times < 1) {
        return func.apply(this, arguments);
      }
    };
  };

  // Object Functions
  // ----------------

  // Retrieve the names of an object's properties.
  // Delegates to **ECMAScript 5**'s native `Object.keys`
  _.keys = nativeKeys || function(obj) {
    if (obj !== Object(obj)) throw new TypeError('Invalid object');
    var keys = [];
    for (var key in obj) if (_.has(obj, key)) keys.push(key);
    return keys;
  };

  // Retrieve the values of an object's properties.
  _.values = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var values = new Array(length);
    for (var i = 0; i < length; i++) {
      values[i] = obj[keys[i]];
    }
    return values;
  };

  // Convert an object into a list of `[key, value]` pairs.
  _.pairs = function(obj) {
    var keys = _.keys(obj);
    var length = keys.length;
    var pairs = new Array(length);
    for (var i = 0; i < length; i++) {
      pairs[i] = [keys[i], obj[keys[i]]];
    }
    return pairs;
  };

  // Invert the keys and values of an object. The values must be serializable.
  _.invert = function(obj) {
    var result = {};
    var keys = _.keys(obj);
    for (var i = 0, length = keys.length; i < length; i++) {
      result[obj[keys[i]]] = keys[i];
    }
    return result;
  };

  // Return a sorted list of the function names available on the object.
  // Aliased as `methods`
  _.functions = _.methods = function(obj) {
    var names = [];
    for (var key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  // Extend a given object with all the properties in passed-in object(s).
  _.extend = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Return a copy of the object only containing the whitelisted properties.
  _.pick = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    each(keys, function(key) {
      if (key in obj) copy[key] = obj[key];
    });
    return copy;
  };

   // Return a copy of the object without the blacklisted properties.
  _.omit = function(obj) {
    var copy = {};
    var keys = concat.apply(ArrayProto, slice.call(arguments, 1));
    for (var key in obj) {
      if (!_.contains(keys, key)) copy[key] = obj[key];
    }
    return copy;
  };

  // Fill in a given object with default properties.
  _.defaults = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      if (source) {
        for (var prop in source) {
          if (obj[prop] === void 0) obj[prop] = source[prop];
        }
      }
    });
    return obj;
  };

  // Create a (shallow-cloned) duplicate of an object.
  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    return _.isArray(obj) ? obj.slice() : _.extend({}, obj);
  };

  // Invokes interceptor with the obj, and then returns obj.
  // The primary purpose of this method is to "tap into" a method chain, in
  // order to perform operations on intermediate results within the chain.
  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  // Internal recursive comparison function for `isEqual`.
  var eq = function(a, b, aStack, bStack) {
    // Identical objects are equal. `0 === -0`, but they aren't identical.
    // See the [Harmony `egal` proposal](http://wiki.ecmascript.org/doku.php?id=harmony:egal).
    if (a === b) return a !== 0 || 1 / a == 1 / b;
    // A strict comparison is necessary because `null == undefined`.
    if (a == null || b == null) return a === b;
    // Unwrap any wrapped objects.
    if (a instanceof _) a = a._wrapped;
    if (b instanceof _) b = b._wrapped;
    // Compare `[[Class]]` names.
    var className = toString.call(a);
    if (className != toString.call(b)) return false;
    switch (className) {
      // Strings, numbers, dates, and booleans are compared by value.
      case '[object String]':
        // Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
        // equivalent to `new String("5")`.
        return a == String(b);
      case '[object Number]':
        // `NaN`s are equivalent, but non-reflexive. An `egal` comparison is performed for
        // other numeric values.
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        // Coerce dates and booleans to numeric primitive values. Dates are compared by their
        // millisecond representations. Note that invalid dates with millisecond representations
        // of `NaN` are not equivalent.
        return +a == +b;
      // RegExps are compared by their source patterns and flags.
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') return false;
    // Assume equality for cyclic structures. The algorithm for detecting cyclic
    // structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
    var length = aStack.length;
    while (length--) {
      // Linear search. Performance is inversely proportional to the number of
      // unique nested structures.
      if (aStack[length] == a) return bStack[length] == b;
    }
    // Objects with different constructors are not equivalent, but `Object`s
    // from different frames are.
    var aCtor = a.constructor, bCtor = b.constructor;
    if (aCtor !== bCtor && !(_.isFunction(aCtor) && (aCtor instanceof aCtor) &&
                             _.isFunction(bCtor) && (bCtor instanceof bCtor))) {
      return false;
    }
    // Add the first object to the stack of traversed objects.
    aStack.push(a);
    bStack.push(b);
    var size = 0, result = true;
    // Recursively compare objects and arrays.
    if (className == '[object Array]') {
      // Compare array lengths to determine if a deep comparison is necessary.
      size = a.length;
      result = size == b.length;
      if (result) {
        // Deep compare the contents, ignoring non-numeric properties.
        while (size--) {
          if (!(result = eq(a[size], b[size], aStack, bStack))) break;
        }
      }
    } else {
      // Deep compare objects.
      for (var key in a) {
        if (_.has(a, key)) {
          // Count the expected number of properties.
          size++;
          // Deep compare each member.
          if (!(result = _.has(b, key) && eq(a[key], b[key], aStack, bStack))) break;
        }
      }
      // Ensure that both objects contain the same number of properties.
      if (result) {
        for (key in b) {
          if (_.has(b, key) && !(size--)) break;
        }
        result = !size;
      }
    }
    // Remove the first object from the stack of traversed objects.
    aStack.pop();
    bStack.pop();
    return result;
  };

  // Perform a deep comparison to check if two objects are equal.
  _.isEqual = function(a, b) {
    return eq(a, b, [], []);
  };

  // Is a given array, string, or object empty?
  // An "empty" object has no enumerable own-properties.
  _.isEmpty = function(obj) {
    if (obj == null) return true;
    if (_.isArray(obj) || _.isString(obj)) return obj.length === 0;
    for (var key in obj) if (_.has(obj, key)) return false;
    return true;
  };

  // Is a given value a DOM element?
  _.isElement = function(obj) {
    return !!(obj && obj.nodeType === 1);
  };

  // Is a given value an array?
  // Delegates to ECMA5's native Array.isArray
  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj) == '[object Array]';
  };

  // Is a given variable an object?
  _.isObject = function(obj) {
    return obj === Object(obj);
  };

  // Add some isType methods: isArguments, isFunction, isString, isNumber, isDate, isRegExp.
  each(['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp'], function(name) {
    _['is' + name] = function(obj) {
      return toString.call(obj) == '[object ' + name + ']';
    };
  });

  // Define a fallback version of the method in browsers (ahem, IE), where
  // there isn't any inspectable "Arguments" type.
  if (!_.isArguments(arguments)) {
    _.isArguments = function(obj) {
      return !!(obj && _.has(obj, 'callee'));
    };
  }

  // Optimize `isFunction` if appropriate.
  if (typeof (/./) !== 'function') {
    _.isFunction = function(obj) {
      return typeof obj === 'function';
    };
  }

  // Is a given object a finite number?
  _.isFinite = function(obj) {
    return isFinite(obj) && !isNaN(parseFloat(obj));
  };

  // Is the given value `NaN`? (NaN is the only number which does not equal itself).
  _.isNaN = function(obj) {
    return _.isNumber(obj) && obj != +obj;
  };

  // Is a given value a boolean?
  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj) == '[object Boolean]';
  };

  // Is a given value equal to null?
  _.isNull = function(obj) {
    return obj === null;
  };

  // Is a given variable undefined?
  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  // Shortcut function for checking if an object has a given property directly
  // on itself (in other words, not on a prototype).
  _.has = function(obj, key) {
    return hasOwnProperty.call(obj, key);
  };

  // Utility Functions
  // -----------------

  // Run Underscore.js in *noConflict* mode, returning the `_` variable to its
  // previous owner. Returns a reference to the Underscore object.
  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  // Keep the identity function around for default iterators.
  _.identity = function(value) {
    return value;
  };

  // Run a function **n** times.
  _.times = function(n, iterator, context) {
    var accum = Array(Math.max(0, n));
    for (var i = 0; i < n; i++) accum[i] = iterator.call(context, i);
    return accum;
  };

  // Return a random integer between min and max (inclusive).
  _.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  };

  // List of HTML entities for escaping.
  var entityMap = {
    escape: {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;'
    }
  };
  entityMap.unescape = _.invert(entityMap.escape);

  // Regexes containing the keys and values listed immediately above.
  var entityRegexes = {
    escape:   new RegExp('[' + _.keys(entityMap.escape).join('') + ']', 'g'),
    unescape: new RegExp('(' + _.keys(entityMap.unescape).join('|') + ')', 'g')
  };

  // Functions for escaping and unescaping strings to/from HTML interpolation.
  _.each(['escape', 'unescape'], function(method) {
    _[method] = function(string) {
      if (string == null) return '';
      return ('' + string).replace(entityRegexes[method], function(match) {
        return entityMap[method][match];
      });
    };
  });

  // If the value of the named `property` is a function then invoke it with the
  // `object` as context; otherwise, return it.
  _.result = function(object, property) {
    if (object == null) return void 0;
    var value = object[property];
    return _.isFunction(value) ? value.call(object) : value;
  };

  // Add your own custom functions to the Underscore object.
  _.mixin = function(obj) {
    each(_.functions(obj), function(name) {
      var func = _[name] = obj[name];
      _.prototype[name] = function() {
        var args = [this._wrapped];
        push.apply(args, arguments);
        return result.call(this, func.apply(_, args));
      };
    });
  };

  // Generate a unique integer id (unique within the entire client session).
  // Useful for temporary DOM ids.
  var idCounter = 0;
  _.uniqueId = function(prefix) {
    var id = ++idCounter + '';
    return prefix ? prefix + id : id;
  };

  // By default, Underscore uses ERB-style template delimiters, change the
  // following template settings to use alternative delimiters.
  _.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g,
    escape      : /<%-([\s\S]+?)%>/g
  };

  // When customizing `templateSettings`, if you don't want to define an
  // interpolation, evaluation or escaping regex, we need one that is
  // guaranteed not to match.
  var noMatch = /(.)^/;

  // Certain characters need to be escaped so that they can be put into a
  // string literal.
  var escapes = {
    "'":      "'",
    '\\':     '\\',
    '\r':     'r',
    '\n':     'n',
    '\t':     't',
    '\u2028': 'u2028',
    '\u2029': 'u2029'
  };

  var escaper = /\\|'|\r|\n|\t|\u2028|\u2029/g;

  // JavaScript micro-templating, similar to John Resig's implementation.
  // Underscore templating handles arbitrary delimiters, preserves whitespace,
  // and correctly escapes quotes within interpolated code.
  _.template = function(text, data, settings) {
    var render;
    settings = _.defaults({}, settings, _.templateSettings);

    // Combine delimiters into one regular expression via alternation.
    var matcher = new RegExp([
      (settings.escape || noMatch).source,
      (settings.interpolate || noMatch).source,
      (settings.evaluate || noMatch).source
    ].join('|') + '|$', 'g');

    // Compile the template source, escaping string literals appropriately.
    var index = 0;
    var source = "__p+='";
    text.replace(matcher, function(match, escape, interpolate, evaluate, offset) {
      source += text.slice(index, offset)
        .replace(escaper, function(match) { return '\\' + escapes[match]; });

      if (escape) {
        source += "'+\n((__t=(" + escape + "))==null?'':_.escape(__t))+\n'";
      }
      if (interpolate) {
        source += "'+\n((__t=(" + interpolate + "))==null?'':__t)+\n'";
      }
      if (evaluate) {
        source += "';\n" + evaluate + "\n__p+='";
      }
      index = offset + match.length;
      return match;
    });
    source += "';\n";

    // If a variable is not specified, place data values in local scope.
    if (!settings.variable) source = 'with(obj||{}){\n' + source + '}\n';

    source = "var __t,__p='',__j=Array.prototype.join," +
      "print=function(){__p+=__j.call(arguments,'');};\n" +
      source + "return __p;\n";

    try {
      render = new Function(settings.variable || 'obj', '_', source);
    } catch (e) {
      e.source = source;
      throw e;
    }

    if (data) return render(data, _);
    var template = function(data) {
      return render.call(this, data, _);
    };

    // Provide the compiled function source as a convenience for precompilation.
    template.source = 'function(' + (settings.variable || 'obj') + '){\n' + source + '}';

    return template;
  };

  // Add a "chain" function, which will delegate to the wrapper.
  _.chain = function(obj) {
    return _(obj).chain();
  };

  // OOP
  // ---------------
  // If Underscore is called as a function, it returns a wrapped object that
  // can be used OO-style. This wrapper holds altered versions of all the
  // underscore functions. Wrapped objects may be chained.

  // Helper function to continue chaining intermediate results.
  var result = function(obj) {
    return this._chain ? _(obj).chain() : obj;
  };

  // Add all of the Underscore functions to the wrapper object.
  _.mixin(_);

  // Add all mutator Array functions to the wrapper.
  each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      var obj = this._wrapped;
      method.apply(obj, arguments);
      if ((name == 'shift' || name == 'splice') && obj.length === 0) delete obj[0];
      return result.call(this, obj);
    };
  });

  // Add all accessor Array functions to the wrapper.
  each(['concat', 'join', 'slice'], function(name) {
    var method = ArrayProto[name];
    _.prototype[name] = function() {
      return result.call(this, method.apply(this._wrapped, arguments));
    };
  });

  _.extend(_.prototype, {

    // Start chaining a wrapped Underscore object.
    chain: function() {
      this._chain = true;
      return this;
    },

    // Extracts the result from a wrapped and chained object.
    value: function() {
      return this._wrapped;
    }

  });

}).call(this);

},{}]},{},[1])
;