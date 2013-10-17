describe "precise math", ->
  beforeEach ->
    @prec = ttm.lib.math.Precise.build()

  it "subtracts", ->
    expect(@prec.sub("5.6", "3.5")).toEqual("2.1")

  it "adds", ->
    expect(@prec.add("5.6", "3.5")).toEqual("9.1")

  it "multiplies", ->
    expect(@prec.mul("5.6", "3.5")).toEqual("19.6")

  it "divides", ->
    expect(@prec.div("5.6", "3.5")).toEqual("1.6")
