#= require lib/logger

describe "javascript logger", ->
  beforeEach ->
    @console_log = jasmine.createSpy()
    @log = ttm.require('logger').build(console_log: @console_log, stringify_objects: false, log_level: 'firehose')

  describe "instrumentation", ->
    it "instruments functions", ->
      function_of_interest = ->
        100
      instr = @log.instrument(name: "function_of_interest", fn: function_of_interest)
      instr(10, 20)
      expect(@console_log.callCount).toEqual 2


    it "correctly instruments objects", ->
      class Funky
        constructor: ->
          @secret = 10
        inspectme: ->
          "secret is #{@secret}"

      x = new Funky
      x.inspectme = @log.instrument(name: "inspectme", fn: x.inspectme)

      expect(x.inspectme()).toEqual "secret is 10"
      expect(@console_log.callCount).toEqual 2

