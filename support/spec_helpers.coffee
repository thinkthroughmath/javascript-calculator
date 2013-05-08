# a number of jasmine-jquery helpers / extensions
# it totally used to do this natively, but now doesn't...

jasmine.getFixtures().findContainer = ->
  $(document.body).find("##{@containerId}")

jasmine.getFixtures().getContainer = ->
  cont = @findContainer()
  if cont.length == 0
    @createContainer_("")
    cont = @findContainer()
  cont

window.f = (html="")->
  cont = jasmine.getFixtures().getContainer();
  if html.length > 0
    cont.html(html)
  cont


beforeEach ->
  @addMatchers(
    toBeInstanceOf: (type)->
      @message = ->
        "Expected #{@actual} to be an instance of #{type.name}"
      @actual instanceof type
    toBeEqualTo: (other)->
      @message = ->
        "Expected #{@actual}.isEqual(#{type}) to be true"
      @actual.isEqual(other)
  )


