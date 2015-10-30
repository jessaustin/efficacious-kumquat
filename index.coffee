{Observable, Subject} = require 'rx'
{run} = require '@cycle/core'
{h, makeDOMDriver} = require '@cycle/dom'
{button, div} = (require 'hyperscript-helpers') h
{item, person, simple} = require './widgets'

itemActions =
#  up$: new Subject
#  down$: new Subject
  remove$: new Subject

intent = (dom, itemActions) ->
  add$:
    dom.select '#add'
      .events 'click'
  remove$:
    itemActions.remove$

model = (dom, actions) ->
  initialState = []
  newItem = ->
    ni = item
      member: person
      dom: dom
      args: editing: yes
    ni.dom = ni.dom.replay null, 1
    ni.dom.connect()
    ni.remove$ = ni.remove$.publish()
    ni.remove$.connect()
    ni
  add$ = actions.add$.map ->
    (items) ->
      items.concat [ newItem() ]
  remove$ = actions.remove$.map (id) ->
    (items) ->
      items.filter (item) ->
        item.id isnt id
  Observable.merge add$, remove$
    .startWith initialState
    .scan (items, mod) -> mod items
    .publishValue initialState
    .refCount()

view = (state$, dom) ->
  state$.map (children) ->
    div [
      div '#list', children.map (t) ->
        t.dom
      button '#add', 'Add Person'
    ]

run (responses) ->
  state$ = model responses.dom, intent responses.dom, itemActions
#  state$.subscribe itemActions.remove$.asObserver()

  dom: view state$, responses.dom
,
  dom: makeDOMDriver '#app'
