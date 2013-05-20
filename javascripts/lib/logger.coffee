ttm.define "logger", ['lib/class_mixer'], (class_mixer)->
  class LogEntry
    initialize: ((@level, @args)->)
    createStrMsg: ->
      message = ''
      for arg in @args
        arg = JSON.stringify(arg) unless typeof arg is 'string'
        message += "#{arg} "
      "#{@level}: #{message}"

    createArrMsg: ->
      ret = []
      current_str = "#{@level}: "
      for arg in @args
        if typeof arg is 'string'
          current_str += " #{arg}"
        else
          ret.push current_str unless current_str.length == 0
          current_str = ""
          ret.push arg
      ret.push current_str unless current_str.length == 0
      ret
    display: (force_string)->
      if force_string
        [@createStrMsg()]
      else
        @createArrMsg()

  class_mixer(LogEntry)

  class InstrumentedFunctionLogEntry
    initialize: ((@args)->)

  class_mixer(InstrumentedFunctionLogEntry)

  class Logger
    initialize: (opts={})->
      @log_entry_types = ['error','warn','info','debug', 'log', 'instrumented']

      @log_entry_display_types = @typesForLevel(opts.log_level || 'production')

      @console_log = opts.console_log
      @stringify_objects = opts.stringify_objects
      @entries = []
      @unique_id = 0

    setLogLevel: (new_level) ->
      @log_entry_display_types  = @typesForLevel(new_level)

    add: (type, args = []) ->
      entry = LogEntry.build(type, args)
      @entries.push entry

      if @log_entry_display_types.indexOf(type) != -1
        @console_log.apply(null, entry.display(@stringify_objects))

    typesForLevel: (level)->
      switch level
        when 'production' then ['error', 'warn']
        when 'firehose' then @log_entry_types # all

    error: -> @add('error', arguments)
    warn:  -> @add('warn', arguments)
    info:  -> @add('info', arguments)
    debug: -> @add('debug', arguments)
    log:   -> @add('log', arguments)

    getUniqueId: -> @unique_id += 1

    instrument: (opts)->
      __logger = @
      ->
        arr = Array.prototype.slice.call(arguments)
        arr.unshift(@)
        arr.unshift "#{opts.name} call: "
        __logger.add('instrumented', arr)
        retval = opts.fn.apply(@, arguments)
        __logger.add('instrumented', ["#{opts.name} return: ", retval])
        retval

  class_mixer Logger



  # integration stuffs
  defaults_log_builder = (opts={})->
    opts = _.extend({}, {
      console_log: ->
        if typeof console != 'undefined' && console.log
          console.log.apply(console, arguments)
      stringify_objects: true
      log_level: 'firehose'
    }, opts)
    Logger.build opts


  return build: defaults_log_builder

