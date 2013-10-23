ttm = thinkthroughmath

describe "javascript logger", ->
  beforeEach ->
    @addMatchers(
      toHaveLogMessgeMatching: (regexp)->
        _(@actual.entries).find((it)-> it.match regexp)
    )
    @console_log = jasmine.createSpy()


  describe "creating different types of loggers", ->
    it "creates a silent logger", ->
      @logger = ttm.Logger.buildSilent console_log: @console_log
      @logger.info "doot"
      expect(@logger).not.toHaveLogMessgeMatching /doot/

    it "creates a verbose logger", ->
      @logger = ttm.Logger.buildVerbose console_log: @console_log
      @logger.info "doot"
      expect(@logger).toHaveLogMessgeMatching /doot/

    it "creates a production logger", ->
      @logger = ttm.Logger.buildProduction console_log: @console_log
      @logger.warn "doot"
      @logger.debug "scoot"
      expect(@logger).toHaveLogMessgeMatching /doot/
      expect(@logger).not.toHaveLogMessgeMatching /scoot/

  describe "instrumentation", ->
    beforeEach ->
      @log = ttm.Logger.build
        console_log: @console_log
        stringify_objects: false
        log_level: 'firehose'

    it "instruments functions", ->
      function_of_interest = ->
        100
      instr = @log.instrument(name: "function_of_interest", fn: function_of_interest)
      ret = instr(10, 20)
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

