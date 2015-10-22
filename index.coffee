{Observable} = require 'rx'
{run} = require '@cycle/core'
{h, makeDOMDriver} = require '@cycle/dom'
{person} = require './widgets'

view = (state) ->
  state.map ->
    h 'div#root', [ h 'person', key: 1, editing: yes ]

run (sources) ->
  dom: view Observable.just no
, dom: makeDOMDriver '#app', {person}
