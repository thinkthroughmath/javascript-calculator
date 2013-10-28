
require './mathjax_gateway'
require './math_buttons'
require './mathml_display'

copy = {}
copy.above_table = "Use the table as a guide."
copy.above_controls = "Use each description and the calculator to build a word equation that represents the problem."

ttm = thinkthroughmath

class_mixer = ttm.class_mixer
historic_value = ttm.lib.historic_value
mathml_converter_builder = ttm.lib.math.ExpressionToMathMLConversion

ui_elements = ttm.widgets.UIElements.build()
math_buttons = ttm.widgets.ButtonBuilder.build(ui_elements: ui_elements)


class EquationBuilder
  initialize: (opts={})->
    @element = opts.element
    @checkCorrectCallback = opts.check_correct_callback
    @image_assets = opts.image_assets || {}
    @renderUsageInstructionNote = opts.renderUsageInstructionNote

    # save the equation builder onto the dom element for external messaging
    opts.element[0].equation_builder = @

    math_button_builder = math_buttons

    @math_lib = ttm.lib.math.math_lib.build()

    expression_component_source = @math_lib.components
    expression_position_builder = @math_lib.expression_position
    @expression_manipulation_source = @math_lib.commands

    @expression_position_value = historic_value.build()
    reset = @expression_manipulation_source.build_reset().perform()
    @expression_position_value.update(reset)

    @buttons = _EquationBuilderButtonsLogic.build(
      math_button_builder,
      @expression_manipulation_source)

    equation_component_retriever = EquationComponentRetriever.
      build(@expression_position_value, @math_lib.traversal)

    mathml_display_modifier = ttm.widgets.EquationBuilderRenderedMathMLModifier.
      build(
        equation_component_retriever
        (id, type)=> @expressionPositionSelected(id, type)
        => @expression_position_value.current()
        @element)

    display = ttm.widgets.MathMLDisplay.build
      mathml_renderer: opts.mathml_renderer
      after_update: ->
        mathml_display_modifier.afterUpdate.apply(mathml_display_modifier, arguments)


    @layout = _EquationBuilderLayout.build(
      display,
      @buttons,
      @image_assets,
      @renderUsageInstructionNote
    )

    @layout.render(@element)

    if opts.variables
      @registerVariables(opts.variables)

    @mathml_converter = mathml_converter_builder.build(@expression_component_source)

    @logic = _EquationBuilderLogic.build(
      (opts)=> @expression_component_source.build_expression(opts),
      @expression_position_value,
      display,
      @mathml_converter,
      )

    @buttons.setLogic @logic
    @logic.updateDisplay()

  registerVariables: (@variables)->
    variable_buttons = @buttons.variableButtons(@variables)
    @layout.renderVariablesInPanel(variable_buttons)
    @layout.renderExplanatoryTableEntries(@variables)

  # leaving in until know is not necessary for tests
  mathML: ->
    @logic.mathML()

  expressionPositionSelected: (id, type)->
    cmd = @expression_manipulation_source.build_update_position(element_id: id, type: type)
    @logic.command(cmd)

  checkCorrect: ->
    checked_json = @math_lib.equation_checking.build(
      @expression_position_value.current(),
      @variables).asJSON()
    math_ml = "<math>#{@mathML()}</math>"
    @checkCorrectCallback(checked_json, math_ml)

  clear: ->
    @logic.command @expression_manipulation_source.build_reset()

  onMathMLChange: (cb)->
    @logic.onMathMLChange cb


class_mixer(EquationBuilder)

class _EquationBuilderLogic
  initialize: (@build_expression, @expression_position, @display, @mathml_converter)->
    @updateDisplay()

  command: (cmd)->
    results = cmd.perform(@expression_position.current())
    @expression_position.update(results)
    @updateDisplay()

  updateDisplay: ->
    mathml = @mathML()
    try
      @mathMLChangeHook && @mathMLChangeHook(mathml)
    @display.update(mathml)

  mathML: ->
    @mathml_converter.convert(@expression_position.current())

  onMathMLChange: (@mathMLChangeHook)->

class_mixer(_EquationBuilderLogic)

# TODO refactor all of these buttons into
class _EquationBuilderButtonsLogic
  initialize: (@builder, @commands)->
    @numbers = @builder.base10Digits(click: (num)=> @numberClick(num))
    @decimal = @builder.decimal click: => @decimalClick()
    @negative_slash_positive = @builder.negative_slash_positive click: => @negativeClick()

    @addition = @builder.addition click: => @additionClick()
    @multiplication = @builder.multiplication click: => @multiplicationClick()
    @division = @builder.division click: => @divisionClick()
    @subtraction = @builder.subtraction click: => @subtractionClick()
    @equals = @builder.equals click: => @equalsClick()
    @clear = @builder.clear click: => @clearClick()
    @del = @builder.del click: => @delClick()
    @square = @builder.exponent value: "square", power: "2", click: => @squareClick()
    @cube = @builder.exponent value: "cube", power: "3", click: => @cubeClick()
    math_var = (name)->
      "<span class='math-variable'>#{name}</span>"
    base = math_var('y')
    power = math_var('x')
    @exponent = @builder.exponent value: "exponentiate", base: base, power: power, click: => @exponentClick()

    math_var = (name)->
      "<span class='math-variable'>#{name}</span>"

    @square_root = @builder.root value: "square-root", radicand: math_var('x'), click: => @squareRootClick()
    @cubed_root = @builder.root value: "cubed-root", degree: "3", radicand: math_var('x'), click: => @cubedRootClick()

    @root = @builder.root degree: math_var('x'), radicand: math_var('y'), click: => @rootClick()

    @lparen = @builder.lparen click: => @lparenClick()
    @rparen = @builder.rparen click: => @rparenClick()
    @pi = @builder.pi click: => @piClick()

    @sin = @builder.fn name: "sin", label: "sin", click: => @sinClick()
    @cos = @builder.fn name: "cos", label: "cos", click: => @cosClick()
    @tan = @builder.fn name: "tan", label: "tan", click: => @tanClick()

    @arcsin = @builder.fn name: "arcsin", label: "arcsin", click: => @arcsinClick()
    @arccos = @builder.fn name: "arccos", label: "arccos", click: => @arccosClick()
    @arctan = @builder.fn name: "arctan", label: "arctan", click: => @arctanClick()


    @fraction = @builder.fraction(click: => @fractionClick())

  setLogic: ((@logic)->)
  variableButtons: (variables)->
    @variables = @builder.variables
      variables: variables,
      click: (variable)=> @variableClick(variable)

  delClick: ->
    @logic.command @commands.build_remove_pointed_at()
  piClick: ->
    @logic.command @commands.build_append_pi(value: "3.14")
  rparenClick: ->
    @logic.command @commands.build_exit_sub_expression()
  lparenClick: ->
    @logic.command @commands.build_append_sub_expression()
  squareClick: ->
    @logic.command @commands.build_append_exponentiation(power: 2)
  cubeClick: ->
    @logic.command @commands.build_append_exponentiation(power: 3)
  exponentClick: ->
    @logic.command @commands.build_append_exponentiation()
  squareRootClick: ->
    @logic.command @commands.build_append_root(degree: 2)
  cubedRootClick: ->
    @logic.command @commands.build_append_root(degree: 3)
  rootClick: ->
    @logic.command @commands.build_append_root()
  decimalClick: ->
    @logic.command @commands.build_append_decimal()
  clearClick: ->
    @logic.command @commands.build_reset()
  equalsClick: ->
    @logic.command @commands.build_append_equals()
  subtractionClick: ->
    @logic.command @commands.build_append_subtraction()
  divisionClick: ->
    @logic.command @commands.build_append_division()
  multiplicationClick: ->
    @logic.command @commands.build_append_multiplication()
  additionClick: ->
    @logic.command @commands.build_append_addition()
  numberClick: (val)->
    @logic.command @commands.build_append_number(value: val.value)
  variableClick: (variable)->
    @logic.command @commands.build_append_variable(variable: variable.value)
  sinClick: ->
    @logic.command @commands.build_append_fn(name: "sin")
  cosClick: ->
    @logic.command @commands.build_append_fn(name: "cos")
  tanClick: ->
    @logic.command @commands.build_append_fn(name: "tan")
  arcsinClick: ->
    @logic.command @commands.build_append_fn(name: "arcsin")
  arccosClick: ->
    @logic.command @commands.build_append_fn(name: "arccos")
  arctanClick: ->
    @logic.command @commands.build_append_fn(name: "arctan")
  fractionClick: ->
    @logic.command @commands.build_append_fraction()
  negativeClick: ->
    @logic.command @commands.build_negate_last()

class_mixer(_EquationBuilderButtonsLogic)

class _EquationBuilderLayout
  initialize: (@display, @buttons, @image_assets={}, @renderUsageInstructionNote)->
  render: (@parent)->
    elt = $("""
      <div class='ttm-equation-builder'>
        <div class='equation-builder-main'>
        </div>
      </div>
    """)
    @wrapper = elt
    @element = elt.find("div.equation-builder-main")

    @parent.append(@wrapper)
    @display.render(class: "equation-display", element: @element)

    @renderExplanatoryTable()
    @renderComponentPanel()
    @renderDropdown()
    @renderNumberPanel()
    @renderAdvancedPanel()
    @renderUsageActivator() if @renderUsageInstructionNote

  renderUsageActivator: ->
    usage_activator = $("""
      <div class='usage-activator'>
        <a href='#'><img src='#{@image_assets.info_icon}' class='info-icon'>How do I use this?</a></div>
    """)
    usage_activator.find('a').on "click", =>
      @showUsageDialog()
      false
    @element.append(usage_activator)

  showUsageDialog: ->
    $("""
    <div class='equation-builder-usage-dialog'>
      <ul>
        <li>Click the descriptions and calculator buttons to build a word equation.</li>
          <blockquote>
            Example: red cars + blue cars = total cars
          </blockquote>
        <li>If you do not have a description for a number you need, click the NUMBERS tab under the calculator.</li>
        <li>Click CLEAR to start a new equation.</li>
      </ul>
    </div> """).dialog({width: 500, height: 300, title: "Equation Builder Instructions"})

  renderDropdown: ->
    advanced_html = """
        <div class='advanced'>
          <div class='buttons'>
            <div class='buttons-wrap'>
            </div>
          </div>
          <div class='link-wrap'><a href='#' class='extra-buttons-handle'><i class='icon-caret-down'></i> Advanced</a></div>
        </div>
    """
    advanced_html = "" # advanced are currently disabled

    arrow_html =
      if @image_assets.arrow_down and @image_assets.arrow_up
        """
          <img src='#{@image_assets.arrow_down}' class='arrow-down'>
          <img src='#{@image_assets.arrow_up}' class='arrow-up'>
        """
       else
        ""


    @extra_buttons = $("""
      <div class='equation-builder-extra-buttons'>
        <div class='numbers'>
          <div class='buttons'>
            <div class='buttons-wrap'>
            </div>
          </div>
          <div class='link-wrap'><a href='#' class='extra-buttons-handle'>
            #{arrow_html}
          Numbers</a></div>
        </div>
        #{advanced_html}
      </div>
    """)
    @wrapper.append @extra_buttons
    @wrapper.find(".arrow-up").hide()

    @extra_buttons.find("a.extra-buttons-handle").on "click", ->
      $(@).find(".arrow-down").toggle()
      $(@).find(".arrow-up").toggle()
      $(@).parent().parent().find(".buttons").slideToggle(400)
      false

  renderNumberPanel: ->
    number_panel = $("<div class='number-panel'></div>")
    @renderNumbers [7..9], number_panel
    @renderNumbers [4..6], number_panel
    @renderNumbers [1..3], number_panel
    @renderNumbers [0], number_panel
    @buttons.decimal.render(element: number_panel)

    @extra_buttons.find(".numbers .buttons  .buttons-wrap").append number_panel


  renderAdvancedPanel: ->
    return # we aren't doing this for now, disabled!
    advanced_panel = $("<div class='advanced-panel'></div>")
    @buttons.sin.render(element: advanced_panel)
    @buttons.cos.render(element: advanced_panel)
    @buttons.tan.render(element: advanced_panel)
    @buttons.arcsin.render(element: advanced_panel)
    @buttons.arccos.render(element: advanced_panel)
    @buttons.arctan.render(element: advanced_panel)
    @extra_buttons.find(".advanced .buttons  .buttons-wrap").append advanced_panel


  renderNumbers: (nums, element)->
    for num in nums
      @buttons.numbers[num].render(element: element)

  renderExplanatoryTable: ->
    @explanatory_table = $("""
      <div class='explanatory-table'>
        <p>#{copy.above_table}</p>
        <table>
          <thead>
            <tr>
              <th class='number'>Number</th>
              <th class='unit'>Unit</th>
              <th class='variable-description'>Description</th>
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      </div>
    """)
    @element.append(@explanatory_table)



  explanatoryTableRow = (variable)->
    value = if variable.is_unknown then "?" else variable.value
    $("""
      <tr>
        <td>#{value}</td>
        <td>#{variable.unit}</td>
        <td>#{variable.name}</td>
      </tr>
    """)

  renderExplanatoryTableEntries: (@variables)->
    tbody = @explanatory_table.find("tbody")
    for v in @variables
      tbody.append(explanatoryTableRow(v))

  renderControlPanel: (parent)->
    control_panel = $("""
      <div class='control-panel'>
      </div>
    """)
    parent.append control_panel

    @buttons.subtraction.render(element: control_panel)
    @buttons.addition.render(element: control_panel)
    @buttons.multiplication.render(element: control_panel)

    @buttons.division.render(element: control_panel)
    @buttons.negative_slash_positive.render(element: control_panel)
    @buttons.fraction.render(element: control_panel)

    @buttons.square.render(element: control_panel)
    @buttons.cube.render(element: control_panel)
    @buttons.exponent.render(element: control_panel)

    @buttons.square_root.render(element: control_panel)
    @buttons.cubed_root.render(element: control_panel)
    @buttons.root.render(element: control_panel)

    @buttons.pi.render(element: control_panel)
    @buttons.lparen.render(element: control_panel)
    @buttons.rparen.render(element: control_panel)

    @buttons.del.render(element: control_panel)
    @buttons.equals.render(element: control_panel)
    @buttons.clear.render(element: control_panel)

  renderComponentPanel: ->
    @component_panel = $("""
      <div class='component-panel'>
        <p>#{copy.above_controls}</p>
      </div>""")
    @element.append(@component_panel)

    @renderVariablePanel(@component_panel)
    @renderControlPanel(@component_panel)

  renderVariablePanel: (parent)->
    @variable_panel = $("""
      <div class='variable-panel'>
      </div>""")
    parent.append(@variable_panel)

  renderVariablesInPanel: (@variable_buttons)->
    for v in @variable_buttons
      v.render(element: @variable_panel)

class_mixer(_EquationBuilderLayout)

class EquationComponentRetriever
  initialize: (@exp_pos_val, @traversal_builder)->
  findForID: (id)->
    exp_pos = @exp_pos_val.current()
    @traversal_builder.build(exp_pos).findForID(id)

class_mixer(EquationComponentRetriever)





EquationBuilder.build_widget = (element)->
  @build({ element: element });


ttm.widgets.EquationBuilder = EquationBuilder
