
ttm = thinkthroughmath
class_mixer = ttm.class_mixer
object_refinement = ttm.lib.object_refinement


# "private methods" to be used in refinements
classes_str = (classes)->
  str = _(classes).join(' ')
  "class='#{str}'"

mathml_cursor_space = (classes=[])->
  cursor_classes = classes.concat ['position-move-target']
  "<mi #{classes_str(cursor_classes)}>&nbsp;</mi>"

class ExpressionToMathMLConversion
  initialize: (@component_source)->
    @component_source ||= ttm.lib.math.ExpressionComponentSource.build()

    refinement = object_refinement.build()
    refinement.forType(@component_source.classes.number,
      {
        toMathML: ->
          "<mn>#{@toDisplay()}</mn>"
      })

    refinement.forType(@component_source.classes.exponentiation,
      {
        toMathML: (opts={})->
          base_opts = ttm.defaults {
            classes: ['exponentiation-base'],
            part_of: 'exponent'
          }, opts
          power_opts = ttm.defaults {
            classes: ['exponentiation-power']
            part_of: 'exponent'
          }, opts

          base = refinement.refine(@base()).toMathML(base_opts)
          power = refinement.refine(@power()).toMathML(power_opts)

          exp_math_ml = "<msup>#{base}#{power}</msup>"

          exp_math_ml
      });

    refinement.forType(@component_source.classes.fn
      {
        toMathML: (opts={})->
          argument_opts = ttm.defaults {
            classes: ['function-argument'],
            part_of: 'function'
          }, opts

          argument = refinement.refine(@argument()).toMathML(argument_opts)
          exp_math_ml = """
            <mrow>
              <mi>#{@name()}</mi>
              #{argument}
            </mrow>
          """
          exp_math_ml
      })

    refinement.forType(@component_source.classes.expression,
      {
        toMathML: (opts={})->
          ret = ConvertExpressionComponentInstance.build(@, refinement).toMathML(opts)
          ret
      });


    refinement.forType(@component_source.classes.equals,
      {
        toMathML: ->
          "<mo>=</mo>"
      });

    refinement.forType(@component_source.classes.addition,
      {
        toMathML: ->
          "<mo>+</mo>"
      });

    refinement.forType(@component_source.classes.multiplication,
      {
        toMathML: ->
          "<mo>&times;</mo>"
      });

    refinement.forType(@component_source.classes.division,
      {
        toMathML: ->
          "<mo>&divide;</mo>"
      });

    refinement.forType(@component_source.classes.subtraction,
      {
        toMathML: ->
          "<mo>-</mo>"
      });

    refinement.forType(@component_source.classes.pi,
      {
        toMathML: ->
          "<mi>&pi;</mi>"
      });

    refinement.forType(@component_source.classes.variable,
      {
        toMathML: ->
          "<mi>#{@name()}</mi>"
      });

    component_source = @component_source
    refinement.forType(@component_source.classes.root,
      {
        isSquareRoot: ->
          degree = @degree()
          if degree.size() == 1
            first = @degree().first()
            first instanceof component_source.classes.number and first.value() == "2"
          else
            false

        toMathML: (opts={})->
          degree_ml = refinement.refine(@degree()).toMathML(opts);
          radicand_ml = refinement.refine(@radicand()).toMathML(opts);
          if @isSquareRoot()
            mathml = "<msqrt>#{radicand_ml}</msqrt>"
          else
            mathml = "<mroot>#{radicand_ml}#{degree_ml}</mroot>"

          mathml += mathml_cursor_space()

      });

    refinement.forType(@component_source.classes.fraction,
      {
        toMathML: (opts={})->
          numerator_opts = ttm.defaults {
            classes: ['fraction-numerator'],
            part_of: 'fraction'
          }, opts
          denominator_opts = ttm.defaults {
            classes: ['fraction-denominator']
            part_of: 'fraction'
          }, opts

          numerator_ml = refinement.refine(@numerator()).toMathML(numerator_opts);
          denominator_ml = refinement.refine(@denominator()).toMathML(denominator_opts);

          mathml = """
            <mfrac>
              <mrow>#{numerator_ml}</mrow>
              <mrow>#{denominator_ml}</mrow>
            </mfrac>
          """
          mathml
      });

    @refinement = refinement


  convert: (expression_position)->
    ret = @refinement.refine(expression_position.expression()).toMathML
      position: expression_position
      is_root_expression: true
    ret

class_mixer ExpressionToMathMLConversion

class ConvertExpressionComponentInstance
  initialize: (@expression, @refinement)->
  toMathML: (@opts={})->
    expression_position = @opts.position
    elem_mathml = @elementsMathML(_.extend({}, @opts, {is_root_expression: false}))
    @wrapInTags(elem_mathml, expression_position)

  elementsMathML: (opts)->
    mathml = ""
    for exp, i in @expression.expression
      mathml += @refinement.refine(exp).toMathML(opts)
    mathml

  wrapInTags: (mathml, expression_position)->
    classes = ["expression-component-id-#{@expression.id()}",
      "expression-component-position-type-inner"].concat(@opts.classes || [])

    classes.push "expression"

    if @opts.is_root_expression
      classes.push 'is-root'
      ret = "<mrow #{@classes_str(classes)}>#{mathml}#{@possibleCursorSpace()}</mrow>"
    else
      ret = """
        <mrow #{@classes_str(classes)}>
          <mo class='opening-parenthesis'>(</mo>
          #{mathml}
          <mo class='closing-parenthesis'>)</mo>
        </mrow>
        """
    ret

  possibleCursorSpace: ->
    if not @shouldShowParentheses()
      mathml_cursor_space()


  shouldShowParentheses: ->
    not @opts.is_root_expression

  classes_str: (classes)->
    str = _(classes).join(' ')
    ret = "class='#{str}'"
    ret


class_mixer ConvertExpressionComponentInstance
ttm.lib.math.ExpressionToMathMLConversion = ExpressionToMathMLConversion
