{Observable} = require 'rx'
{h} = require '@cycle/dom'

intendEvents = (dom, name, xform, event='change') ->
  s = dom.select ".#{name}"
  "#{name}$":
    s.events event
      .map xform

person = ({props, dom}) ->
  console.log 'person', props, dom
  intent = (dom) ->
    Object.assign {},
      intendEvents dom, 'eastern', (ev) -> ev.target.checked
      intendEvents dom, 'edit', ((ev) -> ev), 'click'
      intendEvents dom, 'save', ((ev) -> ev), 'click'
      intendEvents dom, 'cancel', ((ev) -> ev), 'click'
      intendEvents dom, 'given', (ev) -> ev.target.value
      intendEvents dom, 'family', (ev) -> ev.target.value

  model = (props, actions) ->
    console.log 'in model', actions
    editing$ = props.get 'editing'
      .first()
      .concat Observable.merge (actions.edit$.map -> yes), (actions.save$.map -> no)
    console.log editing$
    name$ = Observable.combineLatest (actions.given$.startWith ''), (actions.family$.startWith ''), (given, family) ->
        {given, family}
      .sample editing$
      .map (ev) ->
        console.log 'name', ev
        ev
    console.log name$
    eastern$ = actions.eastern$.startWith no
    Observable.combineLatest editing$, eastern$, name$, (editing, eastern, {given, family}) ->
      {editing, eastern, given, family}

  view = (state$) ->
    console.log 'in view', state$
    state$.map ({editing, eastern, given, family}) ->
      console.log editing, eastern, given, family
      if editing
        g = h 'label', [ 'Given Name: ',
          h 'input.given', type: 'text', key: 'given', value: given
        ]
        f = h 'label', [ 'Family Name: ',
          h 'input.family', type: 'text', key: 'family', value: family
        ]
        others = h 'div', [
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
        others = h 'button.edit', 'Edit'
      h 'div.person',
        if eastern then [f, ' ', g, others] else [g, ' ', f, others]

  dom: view model props, intent dom
#  events:
#    remove: 42

module.exports = {person}
