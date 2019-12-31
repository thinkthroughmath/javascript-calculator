;(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};(function() {
  var root, _base;

  root = window || global;

  root.thinkthroughmath || (root.thinkthroughmath = {});

  (_base = root.thinkthroughmath).widgets || (_base.widgets = {});

  require("./ui_elements");

  require("./math_buttons");

  require("./calculator");

}).call(this);

},{"./calculator":2,"./math_buttons":3,"./ui_elements":4}],2:[function(require,module,exports){
(function() {
  var ButtonLayout, Calculator, CalculatorView, calculator_wrapper_class, class_mixer, components, expression_to_string, historic_value, math_buttons_lib, ttm, ui_elements;

  ttm = thinkthroughmath;

  class_mixer = ttm.class_mixer;

  expression_to_string = ttm.lib.math.ExpressionToString;

  historic_value = ttm.lib.historic_value;

  ui_elements = ttm.widgets.UIElements.build();

  math_buttons_lib = ttm.widgets.ButtonBuilder;

  components = ttm.lib.math.ExpressionComponentSource.build();

  calculator_wrapper_class = 'jc';

  Calculator = (function() {
    function Calculator() {}

    Calculator.build_widget = function(element, buttonsToRender) {
      var math;
      if (buttonsToRender == null) {
        buttonsToRender = null;
      }
      math = ttm.lib.math.math_lib.build();
      return Calculator.build(element, math, ttm.logger, buttonsToRender);
    };

    Calculator.prototype.initialize = function(element, math, logger, buttonsToRender) {
      this.element = element;
      this.math = math;
      this.logger = logger;
      this.buttonsToRender = buttonsToRender;
      this.view = CalculatorView.build(this, this.element, this.math, this.buttonsToRender);
      this.expression_position = historic_value.build();
      this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
      return this.typeLastPressed = "";
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
      this.typeLastPressed = "number";
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
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "exponent";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_exponentiate_last());
    };

    Calculator.prototype.negativeClick = function() {
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "negative";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_negate_last());
    };

    Calculator.prototype.additionClick = function() {
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "addition";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_addition());
    };

    Calculator.prototype.multiplicationClick = function() {
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "multiplication";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_multiplication());
    };

    Calculator.prototype.divisionClick = function() {
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "division";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_division());
    };

    Calculator.prototype.subtractionClick = function() {
      if (this.typeLastPressed === "exponent" || this.typeLastPressed === "lparen") {
        return;
      }
      this.typeLastPressed = "subtraction";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_subtraction());
    };

    Calculator.prototype.decimalClick = function() {
      this.typeLastPressed = "decimal";
      if (this.reset_on_next_number) {
        this.reset_on_next_number = false;
        this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
      }
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_decimal());
    };

    Calculator.prototype.clearClick = function() {
      this.typeLastPressed = "clear";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_reset());
    };

    Calculator.prototype.equalsClick = function() {
      this.typeLastPressed = "equals";
      this.updateCurrentExpressionWithCommand(this.math.commands.build_calculate());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.squareClick = function() {
      this.typeLastPressed = "square";
      this.updateCurrentExpressionWithCommand(this.math.commands.build_square());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.squareRootClick = function() {
      this.typeLastPressed = "squareRoot";
      this.updateCurrentExpressionWithCommand(this.math.commands.build_square_root());
      return this.reset_on_next_number = true;
    };

    Calculator.prototype.lparenClick = function() {
      this.typeLastPressed = "lparen";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_sub_expression());
    };

    Calculator.prototype.rparenClick = function() {
      this.typeLastPressed = "rparen";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_exit_sub_expression());
    };

    Calculator.prototype.piClick = function() {
      this.typeLastPressed = "pi";
      return this.updateCurrentExpressionWithCommand(this.math.commands.build_append_pi());
    };

    return Calculator;

  })();

  class_mixer(Calculator);

  ButtonLayout = (function() {
    function ButtonLayout() {}

    ButtonLayout.prototype.initialize = (function(components, buttonsToRender) {
      this.components = components;
      this.buttonsToRender = buttonsToRender != null ? buttonsToRender : false;
    });

    ButtonLayout.prototype.render = function(element) {
      var defaultButtons;
      this.element = element;
      defaultButtons = ["square", "square_root", "exponent", "clear", "pi", "lparen", "rparen", "division", '7', '8', '9', "multiplication", '4', '5', '6', "subtraction", '1', '2', '3', "addition", '0', "decimal", "negative", "equals"];
      return this.renderComponents(this.buttonsToRender || defaultButtons);
    };

    ButtonLayout.prototype.render_component = function(comp) {
      return this.components[comp].render({
        element: this.element
      });
    };

    ButtonLayout.prototype.renderComponents = function(components) {
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

    CalculatorView.prototype.initialize = function(calc, element, math, buttonsToRender) {
      var buttons, math_button_builder, num, numbers, _i,
        _this = this;
      this.calc = calc;
      this.element = element;
      this.math = math;
      this.buttonsToRender = buttonsToRender;
      math_button_builder = math_buttons_lib.build({
        element: this.element,
        ui_elements: ui_elements
      });
      buttons = {};
      numbers = math_button_builder.base10Digits({
        click: function(val) {
          return _this.calc.numberClick(val);
        }
      });
      for (num = _i = 0; _i <= 9; num = ++_i) {
        buttons["" + num] = numbers[num];
      }
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
      buttons.square = math_button_builder.exponent({
        value: "square",
        power: "2",
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
      this.layout = ButtonLayout.build(buttons, this.buttonsToRender);
      return this.render();
    };

    CalculatorView.prototype.display = function(content) {
      var disp, display_text;
      disp = this.element.find("figure.jc--display");
      disp.html(content);
      disp.scrollLeft(9999999);
      display_text = content.replace(/-/g, "minus");
      return $('#statusMessageContent').html(display_text);
    };

    CalculatorView.prototype.render = function() {
      var calc_div;
      this.element.append("<div class='" + calculator_wrapper_class + "'></div>");
      calc_div = this.element.find("div." + calculator_wrapper_class);
      calc_div.append("<figure class='jc--display'>0</figure>");
      return this.layout.render(calc_div);
    };

    return CalculatorView;

  })();

  class_mixer(CalculatorView);

  ttm.widgets.Calculator = Calculator;

}).call(this);

},{}],3:[function(require,module,exports){
(function() {
  var ButtonBuilder, ttm;

  ttm = thinkthroughmath;

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
            "class": "jc--button jc--button-number",
            ariaLabel: "" + num
          }, opts);
        })(num));
      }
      return _results;
    };

    ButtonBuilder.prototype.decimal = function(opts) {
      return this.button({
        value: ".",
        "class": "jc--button jc--button-decimal",
        ariaLabel: "Decimal Separator"
      }, opts);
    };

    ButtonBuilder.prototype.negative = function(opts) {
      return this.button({
        value: "negative",
        label: "(&#x2013;)",
        "class": "jc--button jc--button-negative",
        ariaLabel: "Negative"
      }, opts);
    };

    ButtonBuilder.prototype.addition = function(opts) {
      return this.button({
        value: "+",
        "class": "jc--button jc--button-operation jc--button-add",
        ariaLabel: "Plus"
      }, opts);
    };

    ButtonBuilder.prototype.subtraction = function(opts) {
      return this.button({
        value: "-",
        label: "&#x2212;",
        "class": "jc--button jc--button-operation jc--button-subtract",
        ariaLabel: "Minus"
      }, opts);
    };

    ButtonBuilder.prototype.multiplication = function(opts) {
      return this.button({
        value: "*",
        label: "&#xd7;",
        "class": "jc--button jc--button-operation jc--button-multiply",
        ariaLabel: "Multiply by"
      }, opts);
    };

    ButtonBuilder.prototype.division = function(opts) {
      return this.button({
        value: "/",
        label: "&#xf7;",
        "class": "jc--button jc--button-operation jc--button-divide",
        ariaLabel: "Divide by"
      }, opts);
    };

    ButtonBuilder.prototype.equals = function(opts) {
      return this.button({
        value: "=",
        "class": "jc--button jc--button-operation jc--button-equal",
        ariaLabel: "Equals"
      }, opts);
    };

    ButtonBuilder.prototype.lparen = function(opts) {
      return this.button({
        value: "(",
        "class": "jc--button jc--button-other jc--button-rParen",
        ariaLabel: "Left parenthesis"
      }, opts);
    };

    ButtonBuilder.prototype.rparen = function(opts) {
      return this.button({
        value: ")",
        "class": "jc--button jc--button-other jc--button-lParen",
        ariaLabel: "Right parenthesis"
      }, opts);
    };

    ButtonBuilder.prototype.pi = function(opts) {
      return this.button({
        value: "pi",
        label: "&#x3c0;",
        "class": "jc--button jc--button-other jc--button-pi",
        ariaLabel: "Pi"
      }, opts);
    };

    ButtonBuilder.prototype.fraction = function(opts) {
      return this.button({
        value: "fraction",
        label: "<sup>a</sup>/<sub>b</sub>",
        "class": "jc--button jc--button-other jc--button-fraction"
      }, opts);
    };

    ButtonBuilder.prototype.caret = function(opts) {
      return this.button({
        value: "^",
        "class": "jc--button jc--button-other jc--button-caret",
        ariaLabel: "Caret"
      }, opts);
    };

    ButtonBuilder.prototype.exponent = function(opts) {
      var base, power;
      base = opts.base || "x";
      power = opts.power || "y";
      return this.button({
        value: "exponent",
        label: "" + base + "<sup>" + power + "</sup>",
        "class": "jc--button jc--button-other jc--button-exponent jc--button-exponent-" + base + "to" + power,
        ariaLabel: "Square"
      }, opts);
    };

    ButtonBuilder.prototype.root = function(opts) {
      var degree, radicand;
      degree = opts.degree ? "" + opts.degree : "";
      radicand = opts.radicand || "x";
      return this.button({
        value: "root",
        label: degree ? "<sup>" + degree + "</sup>&#x221a;" + radicand : "&#x221a;" + radicand,
        "class": "jc--button jc--button-other jc--button-root jc--button-root-" + degree + "of" + radicand,
        ariaLabel: "Square root"
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
              "class": "jc--button jc--button-variable",
              variable: v
            }, opts);
          })(v));
        }
        return _results;
      }).call(this);
      return variables;
    };

    ButtonBuilder.prototype.del = function(opts) {
      return this.button({
        value: "del",
        label: "Delete",
        "class": "jc--button jc--button-del"
      }, opts);
    };

    ButtonBuilder.prototype.clear = function(opts) {
      return this.button({
        value: "clear",
        label: "Clear",
        "class": "jc--button jc--button-clear",
        ariaLabel: "Clear"
      }, opts);
    };

    ButtonBuilder.prototype.button = function(type_opts, opts) {
      return this.ui_elements.button_builder.build(_.extend({}, type_opts, this.opts, opts || {}));
    };

    return ButtonBuilder;

  })();

  ttm.widgets.ButtonBuilder = ttm.class_mixer(ButtonBuilder);

}).call(this);

},{}],4:[function(require,module,exports){
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
      button = $("<button type='button' class='" + opts["class"] + "' value='" + opts.value + "' aria-label='" + opts.ariaLabel + "'>\n  <span class=\"jc--buttonLabel\">\n    " + (opts.label || opts.value) + "\n  </span>\n</button>");
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

},{}]},{},[1,2,3,4])
;