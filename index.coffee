{Observable} = require 'rx'
{run} = require '@cycle/core'
{h, makeDOMDriver} = require '@cycle/dom'
{person, simple} = require './widgets'

intent = (dom) ->
  add$:
    dom.select '#add'
      .events 'click'

model = (dom, actions) ->
  actions.add$.startWith []
    .scan (acc, _, i) ->
      x = person dom: dom, editing: yes
      console.log x
      acc.concat [ x ]

view = (state$, dom) ->
  state$.map (children) ->
    console.log 'view', children
    h 'div#root', [
      h 'div#list', children.map (t) -> t.dom
      h 'button#add', 'Add Person'
    ]

run (responses) ->
  dom: view (model responses.dom, intent responses.dom), responses.dom
,
  dom: makeDOMDriver '#app'
