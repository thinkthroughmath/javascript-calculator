#= require lib
#= require ./base

ttm.queries.fiveStepVariablesforItemID = (item_id, data_callback)->
  # example return value:
  # {"variables":[{"variableValue":"1.5","unitName":"hours","variableName":"time","isUnknown":false},{"variableValue":"12","unitName":"miles","variableName":"distance","isUnknown":false},{"variableValue":"8","unitName":"miles per hour","variableName":"speed","isUnknown":true}]}
  $.getJSON("/items/" + item_id + "/five_step_variables.json", data_callback)
    .error(-> alert("error loading data for five step word problem equation builder") );
