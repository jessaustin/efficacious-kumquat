{Observable} = require 'rx'
{h} = require '@cycle/dom'

intendEvent = (dom, name, event='click', targetProp='value') ->
  "#{name}$":
    dom.select ".#{name}"
      .events event
        .map (ev) -> ev.target[targetProp]

person = ({dom, editing}) ->
  intent = ->
    console.log 'intent'
    Object.assign {},
      intendEvent dom, 'eastern', 'change', 'checked'
      intendEvent dom, 'edit'
      intendEvent dom, 'save'
      intendEvent dom, 'remove'
      intendEvent dom, 'cancel'
      intendEvent dom, 'given', 'change'
      intendEvent dom, 'family', 'change'

  model = (actions) ->
    console.log 'model'
    editing$ = Observable.just editing
      .concat Observable.merge (actions.edit$.map -> yes),
        actions.save$.map -> no
        actions.cancel$.map -> no
      .map (x) ->
        console.log 'editing', x
        x
    name$ = Observable.combineLatest (actions.given$.startWith ''),
        (actions.family$.startWith ''), (given, family) -> {given, family}
      .map (x) ->
        console.log 'name before sample', x
        x
#      .sample editing$
      .map (x) ->
        console.log 'name', x
        x
    eastern$ = actions.eastern$.startWith no
    Observable.combineLatest editing$, eastern$, name$,
      (editing, eastern, {given, family}) ->
        console.log editing, eastern, given, family
        {editing, eastern, given, family}

  view = (state$) ->
    console.log 'view'
    state$.map ({editing, eastern, given, family}) ->
      console.log editing, eastern, given, family
      if editing
        g = h 'label', [ 'Given Name: ',
          h 'input.given', type: 'text', key: 'given', value: given
        ]
        f = h 'label', [ 'Family Name: ',
          h 'input.family', type: 'text', key: 'family', value: family
        ]
        rest = h 'div', [
          h 'label', [
            h 'input.eastern', type: 'checkbox', checked: eastern
            'eastern name order?'
          ]
          h 'button.save', 'Save'
          h 'button.cancel', 'Cancel'
        ]
      else
        g = h 'span.given', key: 'given', given
        f = h 'span.family', key: 'family', family
        rest = h 'button.edit', 'Edit'
      console.log g, f, rest, eastern
      h 'div.person',
        if eastern then [f, ' ', g, rest] else [g, ' ', f, rest]

  dom: view model intent()
#  events:
#    remove: 42

simple = ->
  dom: Observable.just h 'div.simple', 'Simple'

module.exports = {person, simple}
