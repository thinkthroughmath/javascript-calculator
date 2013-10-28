ttm = thinkthroughmath

without_spaces = (str)->
  str.replace(/\s/g, '')

describe "lib/math/expression_to_mathml_conversion", ->
  beforeEach ->
    @expression_to_mathml_conversion = ttm.lib.math.ExpressionToMathMLConversion
    @converter = @expression_to_mathml_conversion.build()
    @math = ttm.lib.math.math_lib.build()
    @exp = @math.object_to_expression.buildExpressionPositionFunction()

  describe "expressionToMathML", ->
    describe "numbers", ->
      it "converts a single number to mathML", ->
        exp = @exp(10)
        expect(@converter.convert(exp)).toMatch /<mn>10<\/mn>/

      it "prints trailing decimals", ->
        exp = @exp('10.')
        expect(@converter.convert(exp)).toMatch /<mn>10.<\/mn>/

    describe "exponentiation", ->
      it "converts an exponent", ->
        exp = @exp '^': [10, 2]
        converted = $(@converter.convert(exp))

        expect(converted.find("msup mrow.exponentiation-base mn").text()).toEqual "10"
        expect(converted.find("msup mrow.exponentiation-power mn").text()).toEqual "2"

    it "converts multiplication", ->
      exp = @exp 10, '*', 2

      converted = $(@converter.convert(exp))
      expect(converted.find("mn:eq(0)").text()).toEqual "10"
      expect(converted.find("mo").text()).toEqual $("<p>&times;</p>").text()
      expect(converted.find("mn:eq(1)").text()).toEqual "2"

    it "converts division", ->
      exp = @exp 10, '/', 2

      converted = $(@converter.convert(exp))
      expect(converted.find("mn:eq(0)").text()).toEqual "10"
      expect(converted.find("mo").text()).toEqual $("<p>&divide;</p>").text()
      expect(converted.find("mn:eq(1)").text()).toEqual "2"

    it "converts subtraction", ->
      exp = @exp 10, '-', 2


      converted = $(@converter.convert(exp))
      expect(converted.find("mn:eq(0)").text()).toEqual "10"
      expect(converted.find("mo").text()).toEqual '-'
      expect(converted.find("mn:eq(1)").text()).toEqual "2"

    it "converts pi", ->
      exp = @exp 10, 'pi', 2

      converted = $(@converter.convert(exp))
      expect(converted.find("mn:eq(0)").text()).toEqual "10"
      expect(converted.find("mi:first").text()).toEqual $("<p>&pi;</p>").text()
      expect(converted.find("mn:eq(1)").text()).toEqual "2"


    it "correctly renders square roots", ->
      exp = @exp(10, '*', {root: [2, 109]})

      converted = $(@converter.convert(exp))
      expect(converted.find("msqrt mn").text()).toEqual "109"

    it "correctly renders varaibles", ->
      exp = @exp(variable: "luke")

      converted = $(@converter.convert(exp))
      expect(converted.find("mi:first").text()).toEqual "luke"

    it "correctly renders fractions", ->
      exp = @exp(fraction: [1,2])
      converted = $(@converter.convert(exp))
      expect(converted.find("mfrac").length).not.toEqual 0

    describe "sub-expressions", ->
      it "correctly adds parentheses to a complete sub-expression", ->
        exp = @exp(10, '*', [2, '-', 3], '=')

        converted = $(@converter.convert(exp))
        expect(converted.find("mrow mo.opening-parenthesis").length).toBeTruthy()
        expect(converted.find("mrow mo.closing-parenthesis").length).toBeTruthy()

    describe "expressions", ->
      it "adds the 'expression' class so that equation builder mathml modifier can add a cursor", ->
        exp = @exp()
        converted = $(@converter.convert(exp))
        expect(converted.is("mrow.expression")).toBeTruthy()



