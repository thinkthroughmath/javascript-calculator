#= require lib/class_mixer

class_mixer = ttm.class_mixer

class LogEntry
  initialize: ((@level, @args)->)
  createStrMsg: (index)->
    message = ''
    for arg in @args
      arg = JSON.stringify(arg) unless typeof arg is 'string'
      message += "#{arg} "
    "#{@levelAndEntryIndexString()} #{message}"

  createArrMsg: (index)->
    ret = []
    current_str = @levelAndEntryIndexString()

    for arg in @args
      if typeof arg is 'string'
        current_str += " #{arg}"
      else
        ret.push current_str unless current_str.length == 0
        current_str = ""
        ret.push arg
    ret.push current_str unless current_str.length == 0
    ret

  levelAndEntryIndexString: ()->
    "#{@level} (##{@index}):"

  display: (force_string, @index)->
    if force_string
      [@createStrMsg()]
    else
      @createArrMsg()

  match: (regexp)->
    @createStrMsg().match regexp


class_mixer(LogEntry)

class InstrumentedFunctionLogEntry
  initialize: ((@args)->)
class_mixer(InstrumentedFunctionLogEntry)

class Logger
  initialize: (opts={})->
    @console_log = opts.console_log
    @stringify_objects = opts.stringify_objects

    @logging_policy = opts.logging_policy

    @entries = []
    @unique_id = 0

  # setLogLevel: (new_level) ->
  #   @log_entry_display_types  = @typesForLevel(new_level)

  add: (type, args = []) ->
    entry = LogEntry.build(type, args)
    return unless @logging_policy.acceptIncoming(entry)

    @entries.push entry
    entry_index = @entries.length - 1

    @console_log.apply(null, entry.display(@stringify_objects, entry_index))

  lookup: (num)->
    @entries[num]

  error: -> @add('error', arguments)
  warn:  -> @add('warn', arguments)
  info:  -> @add('info', arguments)
  debug: -> @add('debug', arguments)
  log:   -> @add('log', arguments)

  getUniqueId: -> @unique_id += 1

  instrument: (opts)->
    __logger = @
    ->
      id = __logger.getUniqueId()
      arr = Array.prototype.slice.call(arguments)
      arr.unshift(@)
      arr.unshift "#{opts.name} call (id #{id}): "
      __logger.add('instrumented', arr)
      retval = opts.fn.apply(@, arguments)
      __logger.add('instrumented', ["#{opts.name} return (id #{id}): ", retval])
      retval

  logMethodCall: (name, object, method, args)->
    id = @getUniqueId()
    @info("method call (id #{id}): ", name, object, method, args)
    ret = object[method].apply(object, args)
    @info("method call return (id #{id}): ", name, method, args, ret)
    ret

class_mixer Logger

class LoggerPolicy
  initialize: ->
    @log_entry_types = ['error','warn','info','debug', 'log', 'instrumented']
    @log_entry_display_types = @typesForLevel('production')

  typesForLevel: (level)->
    switch level
      when 'production' then ['error', 'warn']
      when 'firehose' then @log_entry_types # all

  logLevelActive: (level)->
    @log_entry_display_types.indexOf(level) != -1

class_mixer LoggerPolicy

class SilentLoggerPolicy extends LoggerPolicy
  acceptIncoming: ->
    false
class_mixer SilentLoggerPolicy

class VerboseLoggerPolicy extends LoggerPolicy
  acceptIncoming: ->
    true
class_mixer VerboseLoggerPolicy


class ProductionLoggerPolicy extends LoggerPolicy
  acceptIncoming: (entry)->
    @logLevelActive(entry.level)
class_mixer ProductionLoggerPolicy


class LoggerBuilder
  build: (opts={})->
    opts = ttm.defaults(opts, {
      console_log: ->
        if typeof console != 'undefined' && console.log
          console.log.apply(console, arguments)
      stringify_objects: true
      log_level: 'firehose'
      logging_policy: VerboseLoggerPolicy.build()
    })
    Logger.build opts

  buildSilent: (opts={})->
    silent = SilentLoggerPolicy.build()
    @build(ttm.defaults(opts, {logging_policy: silent}))

  buildVerbose: (opts)->
    @build(opts)

  buildProduction: (opts={})->
    prod_policy = ProductionLoggerPolicy.build()
    @build(ttm.defaults(opts, {logging_policy: prod_policy}))

class_mixer LoggerBuilder

# library export
window.ttm.Logger = LoggerBuilder.build()
