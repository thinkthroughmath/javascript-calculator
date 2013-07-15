# it_adheres_to_button_interface = (opts={})->
# make this later ^^

describe "math buttons", ->
  beforeEach ->
    ui_elements = window.ttm.widgets.UIElements.build()
    @btns = window.ttm.widgets.ButtonBuilder.build(ui_elements: ui_elements)

  describe "delete button", ->
    it "has the value 'del'", ->
      @btns.del().render(element: f())
      expect(f().find("[value='del']").length).not.toEqual(0)

