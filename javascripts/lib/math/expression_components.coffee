#= require lib/math/base

class ExpressionComponent
  isOperator: -> false
  isNumber: -> false
  preceedingSubexpression: -> false
  clone: -> @ # by default, cloning does nothing

class Equals extends ExpressionComponent
  toString: -> "="
  isOperator: -> true
ttm.class_mixer(Equals)


class Expression extends ExpressionComponent
  @buildWithContent: (content)->
    @build(expression: content)

  @buildError: (content)->
    @build(is_error: true)

  @buildUnlessExpression: (content)->
    if content instanceof @
      content
    else
      @buildWithContent([content])

  initialize: (opts={})->
    defaults =
      is_open: false
      expression: []
      is_error: false
    opts = _.extend({}, defaults, opts)
    @expression = opts.expression
    @is_error = opts.is_error
    @is_open = opts.is_open

  clone: (new_vals={})->
    data =
      expression: _.map(@expression, (it)-> it.clone())
      is_error: @is_error
      is_open: @is_open
    @klass.build(_.extend({}, data, new_vals))

  # returns part of an expression
  last: (from_end=0)->
    @expression[@expression.length - 1 - from_end]

  first: ->
    _.first(@expression)

  nth: (n)->
    @expression[n]

  reset: ->
    @expression = []

  size: ->
    _(@expression).size();

  isBlank: ->
    @size() == 0

  set: (expression)->
    @expression = expression

  append: (new_last)->
    expr = _.clone(@expression)
    expr.push new_last
    @clone(expression: expr)

  replaceLast: (new_last)->
    @withoutLast().append(new_last)

  withoutLast: ->
    expr = _.clone(@expression)
    expr = expr.slice(0, expr.length-1)
    @clone(expression: expr)

  isError: -> @is_error

  isOpen: -> @is_open
  open: -> @clone(is_open: true)
  close: -> @clone(is_open: false)

  toString: ->
    tf = (it)-> it ? "t" : "f"
    subexpressions = _(@expression).chain().map((it)->
      it.toString()).join(", ").value()
    "Expression(o: #{tf @is_open}, e: #{tf @is_error}, exp: [#{subexpressions}])"

ttm.class_mixer(Expression)


class Number extends ExpressionComponent
  initialize: (opts)->
    @val = opts.value
    @future_as_decimal = opts.future_as_decimal

  toString: ->
    "##{@val}"

  isNumber: -> true

  negated: ->
    value = @val * -1
    Number.build(value: value)

  toCalculable: ->
    parseFloat(@val)

  clone: (opts={})->
    opts = _.extend({},
      {
        value: @val
        future_as_decimal: @future_as_decimal
      },
      opts)
    Number.build(opts)

  value: -> @val

  concatenate: (number)->
    new_val =
      if @future_as_decimal
        "#{@val}.#{number}"
      else
        "#{@val}#{number}"
    Number.build(value: new_val)

  futureAsDecimal: ->
    future_as_decimal = !@hasDecimal()
    @clone(future_as_decimal: future_as_decimal)

  hasDecimal: ->
    /\./.test(@val)

ttm.class_mixer(Number)

class Exponentiation extends ExpressionComponent
  initialize: (opts={})->
    @baseval = opts.base
    @powerval = opts.power
  isOperator: -> true
  base: -> @baseval
  power: -> @powerval

  preceedingSubexpression: -> @base()

  updatePower: (power)->
    @klass.build base: @base(), power: power

  toString: ->
    "^(b: #{@base().toString()}, p: #{@power().toString()})"

  isPowerOpen: -> @power().isOpen()

ttm.class_mixer(Exponentiation)

class Pi extends ExpressionComponent
  toString: -> "PI"
ttm.class_mixer(Pi)

class Addition extends ExpressionComponent
  toString: -> "Add"
  isOperator: -> true
ttm.class_mixer(Addition)

class Subtraction extends ExpressionComponent
  isOperator: -> true
  toString: -> "Sub"
ttm.class_mixer(Subtraction)

class Multiplication extends ExpressionComponent
  isOperator: -> true
  toString: -> "Mult"
ttm.class_mixer(Multiplication)

class Division extends ExpressionComponent
  isOperator: -> true
  toString: -> "Div"
ttm.class_mixer(Division)

class Blank extends ExpressionComponent
  toString: -> "Blnk"
ttm.class_mixer(Blank)

class Root extends ExpressionComponent
  initialize: (opts={})->
    @degree_value = opts.degree
    @radicand_value = opts.radicand

  toString: ->
    "Root(deg: #{@degree().toString()}, rad: #{@radicand().toString()})"

  degree: -> @degree_value

  radicand: -> @radicand_value

  updateRadicand: (new_radic)->
    @clone(radicand: new_radic)

  clone: (new_vals={})->
    data =
      degree: @degree_value
      radicand: @radicand_value
    @klass.build(_.extend({}, data, new_vals))

ttm.class_mixer(Root)

class Variable extends ExpressionComponent
  initialize: (opts={})->
    @name_value = opts.name
  name: -> @name_value
  toString: ->
    "Var(#{@name()})"
ttm.class_mixer(Variable)

class ExpressionIDSource
  initialize: ->
    @id = 0
  next: ->
    ++@id;
  current: ->
    @id;

ttm.class_mixer(ExpressionIDSource)

components =
  expression: Expression
  number: Number
  addition: Addition
  multiplication: Multiplication
  division: Division
  subtraction: Subtraction
  exponentiation: Exponentiation
  pi: Pi
  equals: Equals
  blank: Blank
  root: Root
  variable: Variable


class ExpressionComponentSource
  initialize: ->
    @id_source = ExpressionIDSource.build()
  classes: components

for name, klass of components
  build_klass = do (name, klass)->
    (opts={})->
      opts.id ||= @id_source.next()
      klass.build(opts)

  ExpressionComponentSource.prototype["build_#{name}"] = build_klass


ttm.lib.math.ExpressionComponentSource =
  ttm.class_mixer(ExpressionComponentSource)

