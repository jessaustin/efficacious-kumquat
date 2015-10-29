{Observable} = require 'rx'
{h} = require '@cycle/dom'
{button, div, input, label, span} = (require 'hyperscript-helpers') h

# boilerplate for intent
intendEvent = (dom, id, name, event='click', targetProp='value') ->
  "#{name}$":
    dom.select ".#{name}_#{id}"
      .events event
      .map (ev) ->
        ev.target[targetProp]

# uniqueness
count = do (n = 0) ->
  loop
    yield n++

# items go in arrays, and handle reordering and removal of children
item = ({dom, member, args}) ->
  console.log 'item', dom, member, args
  id = count.next().value
  member = member Object.assign (args ? {}), {dom, id}

  intent = ->
    Object.assign {},
#      intendEvent dom, id, 'up'
#      intendEvent dom, id, 'down'
      intendEvent dom, id, 'remove'
      intendEvent dom, id, 'cancel'
      intendEvent dom, id, 'really'
      member$: member.dom

  model = (actions) ->
#    up$ = actions.up$
#    down$ = actions.down$
#    reorder$ = Observable.merge (up$.map -> undefined),
#      down$.map -> undefined
    initRemove$ = actions.remove$
    cancelRemove$ = actions.cancel$
    removing$ = Observable.just no
      .merge initRemove$.map(-> yes), cancelRemove$.map -> no
    reallyRemove$ = actions.really$
      .map -> id
    state$ = Observable.combineLatest removing$,
      Observable.just null
        .concat actions.member$
        .map (t) ->
          console.log 't', t
          t
    {state$, reallyRemove$}
#    {reorder$, removing$, reallyRemove$}

  view = ({state$}) ->
    state$.map ([remove, member]) ->
      div ".item#item#{id}", [
        console.log 'view', remove, member
        member
        div '.controls',
          if remove
            [ button ".cancel_#{id}", "Cancel Removal"
              button ".really_#{id}", "Really Remove"
            ]
          else
#            [ button ".up_#{id}", "Up"
#              button ".down_#{id}", "Down"
            [ button ".remove_#{id}", "Remove"
            ]
      ]
  actions = intent()
  console.log 'actions', actions
  state = model actions

  dom: view state
#    reorder: state.reorder$
  remove$: state.reallyRemove$
  id: id

person = ({dom, editing, id}) ->
  console.log 'person', dom, editing, id
  intent = ->
    Object.assign {},
      intendEvent dom, id, 'eastern', 'change', 'checked'
      intendEvent dom, id, 'edit'
      intendEvent dom, id, 'save'
      intendEvent dom, id, 'cancel'
      intendEvent dom, id, 'given', 'change'
      intendEvent dom, id, 'family', 'change'

  model = (actions) ->
    editing$ = Observable.just editing
      .concat Observable.merge (actions.edit$.map -> yes),
        actions.save$.map -> no
        actions.cancel$.map -> no
    given$ = actions.given$.startWith ''
    family$ = actions.family$.startWith ''
    eastern$ = actions.eastern$.startWith no
    value$ = Observable.combineLatest given$, family$, eastern$
      .sample actions.save$.startWith ''
    Observable.combineLatest editing$, value$

  view = (state$) ->
    state$.map ([editing, [given, family, eastern]]) ->
      console.log 'person view', editing, given, family, eastern
      if editing
        console.log 'editing!'
        g = label [
          'Given Name: '
          input ".given_#{id}", type: 'text', value: given
        ]
        f = label [
          'Family Name: '
          input ".family_#{id}", type: 'text', value: family
        ]
        rest = div [
          label [
            input ".eastern_#{id}", type: 'checkbox', checked: eastern
            'eastern name order?'
          ]
          button ".save_#{id}", 'Save'
          button ".cancel_#{id}", 'Cancel'
        ]
      else
        g = span ".given_#{id}", given
        f = span ".family_#{id}", family
        rest = button ".edit_#{id}", 'Edit'
      console.log g, f, rest
      div ".person_#{id}",
        if eastern then [f, ' ', g, rest] else [g, ' ', f, rest]

  dom: view model intent()

simple = ->
  dom: Observable.just div '.simple', 'Simple'

module.exports = {item, person, simple}
