# This pulls in all your specs from the javascripts directory into Jasmine:
#
# spec/javascripts/*_spec.js.coffee
# spec/javascripts/*_spec.js
# spec/javascripts/*_spec.js.erb
# IT IS UNLIKELY THAT YOU WILL NEED TO CHANGE THIS FILE
#
#= require ../../app/assets/javascripts/lib
#= require jquery
#= require jquery_ujs
#= require ../../vendor/assets/javascripts/underscore-min
#= require_tree ./support
#= require_tree ../../app/assets/javascripts/widgets
#= require_tree ./
#= require ../../app/assets/javascripts/data_warehouse
