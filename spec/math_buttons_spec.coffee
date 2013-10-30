ttm = thinkthroughmath




describe "math buttons", ->
  beforeEach ->
    ui_elements = ttm.widgets.UIElements.build()
    @btns = ttm.widgets.ButtonBuilder.build(ui_elements: ui_elements)

  describe "delete button", ->
    it "has the value 'del'", ->
      @btns.del().render(element: f())
      expect(f().find("[value='del']").length).not.toEqual(0)

