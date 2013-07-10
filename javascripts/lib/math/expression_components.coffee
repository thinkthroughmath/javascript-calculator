#= require lib/math/base

class ExpressionComponent
  initialize: (opts={})->
    @id_value = opts.id
    @parent_value = opts.parent
  isNumber: -> false
  preceedingSubexpression: -> false
  cloneData: (opts)=> ttm.defaults(opts, {id: @id_value, parent: @parent_value})
  clone: (opts={})-> @klass.build(@cloneData(opts))
  id: -> @id_value
  subExpressions: -> []
  parent: -> @parent_value
  withParent: (parent)->
    ret = @clone(parent: parent)

  # @destructive
  replaceImmediateSubComponentD: (field, old_comp, new_comp)->
    for comp, index in @[field]
      if comp.id() == old_comp.id()
        new_comp = new_comp.withParent(@)
        @[field][index] = new_comp
    null

class Equals extends ExpressionComponent
  toString: -> "="
ttm.class_mixer(Equals)


class Expression extends ExpressionComponent
  @buildWithContent: (content)->
    @build(expression: content)

  @buildError: (content)->
    @build(is_error: true)

  @buildUnlessExpression: (content)->
    if content instanceof @comps.classes.expression
      content
    else
      @buildWithContent([content])

  initialize: (opts={})->
    super
    defaults =
      is_open: false
      expression: []
      is_error: false
    opts = _.extend({}, defaults, opts)

    @expression = []
    for part in opts.expression
      @expression.push(part.withParent(@))

    @is_error = opts.is_error
    @is_open = opts.is_open

  cloneData: (new_vals={})->
    ttm.defaults(super,
    {
      expression: _.map(@expression, (it)-> it.clone())
      is_error: @is_error
      is_open: @is_open
      id: @id_value
    })

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

  isEmpty: -> @isBlank()

  set: (expression)->
    @expression = expression

  append: (new_last)->
    expr = _.clone(@expression)
    expr.push new_last.withParent(@)
    @clone(expression: expr)

  # @destructive
  appendD: (new_last)->
    @expression.push new_last.withParent(@)

  # replace old comp with new comp if it is contained
  # immediately within this expression
  replaceD: (old_comp, new_comp)->
    @replaceImmediateSubComponentD("expression", old_comp, new_comp)

  replaceLast: (new_last)->
    @withoutLast().append(new_last.withParent(@))

  # @destructive
  replaceLastD: (new_last)->
    @expression[@expression.length-1] = new_last.withParent(@)

  withoutLast: ->
    expr = _.clone(@expression)
    expr = expr.slice(0, expr.length-1)
    @clone(expression: expr)

  # @destructive
  withoutLastD: ->
    @expression.splice(@expression.length-1, 1)

  isError: -> @is_error

  isOpen: -> @is_open
  open: -> @clone(is_open: true)
  close: -> @clone(is_open: false)
  closeD: -> @is_open = false;

  toString: ->
    tf = (it)-> it ? "t" : "f"
    subexpressions = _(@expression).chain().map((it)->
      it.toString()).join(", ").value()
    "Expression(o: #{tf @is_open}, e: #{tf @is_error}, exp: [#{subexpressions}])"

  subExpressions: -> @expression

ttm.class_mixer(Expression)


class Number extends ExpressionComponent
  initialize: (opts)->
    super
    @val = opts.value
    @future_as_decimal = opts.future_as_decimal

  toString: ->
    "##{@val}"

  isNumber: -> true

  negated: ->
    value = @val * -1
    Number.build(value: value)

  # @destructive
  negatedD: ->
    @val *= -1

  toCalculable: ->
    parseFloat(@val)

  cloneData: (opts={})->
    ttm.defaults(super,
      {
        value: @val
        future_as_decimal: @future_as_decimal
      })

  value: -> @val

  concatenate: (number)->
    new_val =
      if @future_as_decimal
        "#{@val}.#{number}"
      else
        "#{@val}#{number}"
    Number.build(value: new_val)

  # @destructive
  concatenateD: (number)->
    if @future_as_decimal
      @val = "#{@val}.#{number}"
    else
      @val = "#{@val}#{number}"
    @future_as_decimal = false

  futureAsDecimal: ->
    future_as_decimal = !@hasDecimal()
    @clone(future_as_decimal: future_as_decimal)

  # @destructive
  futureAsDecimalD: (value)->
    @future_as_decimal = value

  hasDecimal: ->
    /\./.test(@val)

ttm.class_mixer(Number)

class Exponentiation extends ExpressionComponent
  initialize: (opts={})->
    super
    @baseval = opts.base
    @powerval = opts.power
  base: -> @baseval
  power: -> @powerval

  preceedingSubexpression: -> @base()

  updatePower: (power)->
    @klass.build base: @base(), power: power

  toString: ->
    "^(b: #{@base().toString()}, p: #{@power().toString()})"

  isPowerOpen: -> @power().isOpen()

  subExpressions: ->
    [@base(), @power()]

  clone: (new_vals={})->
    data =
      base: @base().clone()
      power: @power().clone()
      id: @id_value
    base_data = @cloneData()
    other = @klass.build(_.extend({}, base_data, data, new_vals))
    other

  # replace old comp with new comp if it is contained
  # immediately within this exponentiation
  replaceD: (old_comp, new_comp)->
    @baseval.replaceD(old_comp, new_comp)
    @powerval.replaceD(old_comp, new_comp)

ttm.class_mixer(Exponentiation)

class Pi extends ExpressionComponent
  toString: -> "PI"
ttm.class_mixer(Pi)

class Addition extends ExpressionComponent
  toString: -> "Add"
ttm.class_mixer(Addition)

class Subtraction extends ExpressionComponent
  toString: -> "Sub"
ttm.class_mixer(Subtraction)

class Multiplication extends ExpressionComponent
  toString: -> "Mult"
ttm.class_mixer(Multiplication)

class Division extends ExpressionComponent
  toString: -> "Div"
ttm.class_mixer(Division)


class Fraction extends ExpressionComponent
  initialize: (opts={})->
    super
    @numerator_value = opts.numerator
    @denominator_value = opts.denominator

  toString: ->
    "Frac(num: #{@numerator().toString()}, den: #{@denominator().toString()})"

  numerator: ->
    @numerator_value

  denominator: ->
    @denominator_value

  subExpressions: ->
    [@numerator(), @denominator()]

  clone: (new_vals={})->
    data =
      numerator: @numerator().clone()
      denominator: @denominator().clone()
    base_data = @cloneData()
    other = @klass.build(_.extend({}, base_data, data, new_vals))
    other


ttm.class_mixer(Fraction)

class Blank extends ExpressionComponent
  toString: -> "Blnk"
ttm.class_mixer(Blank)

class Root extends ExpressionComponent
  initialize: (opts={})->
    super
    @degree_value = opts.degree
    @radicand_value = opts.radicand

  toString: ->
    "Root(deg: #{@degree().toString()}, rad: #{@radicand().toString()})"

  degree: -> @degree_value

  radicand: -> @radicand_value

  updateRadicand: (new_radic)->
    @clone(radicand: new_radic)


  cloneData: (new_vals={})->

    data =
      degree: @degree_value && @degree_value.clone()
      radicand: @radicand_value && @radicand_value.clone()

    ttm.defaults(super, data)


  # clone: (new_vals={})->
  #   data =
  #     degree: @degree_value
  #     radicand: @radicand_value
  #   @klass.build()

  subExpressions: ->
    [@degree(), @radicand()]

  # replace old comp with new comp if it is contained
  # immediately within this root
  replaceD: (old_comp, new_comp)->
    @degree_value.replaceD(old_comp, new_comp)
    @radicand_value.replaceD(old_comp, new_comp)


ttm.class_mixer(Root)

class Variable extends ExpressionComponent
  initialize: (opts={})->
    super
    @name_value = opts.name
  name: -> @name_value
  clone: (new_vals={})->
    data =
      name: @name_value
    base_data = @cloneData()
    @klass.build(_.extend({}, base_data, data, new_vals))

  toString: ->
    "Var(#{@name()})"
ttm.class_mixer(Variable)

class Fn extends ExpressionComponent
  initialize: (opts={})->
    super

    # we only support single-argument functions
    @name_value = opts.name
    @argument_value = opts.argument

  cloneData: (new_vals={})->
    ttm.defaults(super, {
      name: @name_value
      argument: @argument() && @argument().clone()
    })

  subExpressions: ->
    [@argument()]

  toString: ->
    "Fn(name: #{@name()}, argument: #{@argument().toString()})"

  argument: ->
    @argument_value

  name: ->
    @name_value

ttm.class_mixer(Fn)

class ExpressionIDSource
  initialize: ->
    @id = 0
  next: ->
    next = ++@id
    next
  current: ->
    @id

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
  fraction: Fraction
  fn: Fn

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

