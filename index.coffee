{run, Rx} = require '@cycle/core'
{h, makeDOMDriver} = require '@cycle/dom'
{nameWidget} = require './widgets'

intent = (dom) ->
  change$:
    dom.select '.given'
      .events 'changeGiven$'
      .map (ev) ->
#        console.log ev
        ev.detail

model = ({change$}) ->
#  console.log change$
  change$.map (action) ->
#    console.log action
    action

view = (state) ->
#  console.log state
  state.map (state) ->
    console.log 'here!'
    h 'namewidget', key: 0, given: '', family: '', eastern: false
#  console.log x
#  dom: x
#    h 'div', [ h 'div' ]#, key: 0, given: '', family: '', eastern: false

driver = makeDOMDriver '#app', 'namewidget': nameWidget
#console.log driver
#console.log nameWidget

run ({dom}) ->
  console.log dom
  dom = view model intent dom
  console.log dom
  {dom}
,
  dom: driver
