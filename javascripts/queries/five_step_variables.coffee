#= require lib
#= require ./base

ttm.queries.fiveStepVariablesforItemID = (item_id, data_callback)->
  $.getJSON("/items/" + item_id + "/five_step_variables.json", data_callback)
    .error(-> alert("error loading data for five step word problem equation builder") );
