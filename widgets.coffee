{Rx: {Observable: {combineLatest}}} = require '@cycle/core'
{h} = require '@cycle/dom'

module.exports =
  nameWidget: (responses) ->
    console.log responses

    intent = ({dom}) ->
      console.log dom
      changeGiven$:
        dom.select '.given'
          .events 'input'
          .map (ev) ->
            console.log ev
            ev.target.value
      changeFamily$:
        dom.select '.family'
          .events 'input'
          .map (ev) -> ev.target.value
      changeEastern$:
        dom.select '.eastern'
          .events 'input'
          .map (ev) -> ev.target.checked

    model = (actions) ->
      o = combineLatest actions.changeGiven$.startWith '',
        actions.changeFamily$.startWith ''
        actions.changeEastern$.startWith false
        (given, family, eastern) -> {given, family, eastern}
      console.log o
      o

    view = (state$) ->
      state$.map (state) ->
        givenNode = h 'label', [
          'Given Name: '
          h 'input.given', type: 'text', value: state.given
        ]
        familyNode = h 'label', [
          'Family Name: '
          h 'input.family', type: 'text', value: state.family
        ]
        easternNode = h 'label', [
          'eastern order?'
          h 'input.eastern', type: 'checkbox', checked: state.eastern
        ]
        if state.eastern
          h 'div', [ familyNode , givenNode , easternNode ]
        else
          h 'div', [ givenNode , familyNode , easternNode ]

    actions = intent responses
    rv =
      dom:
        view model actions
      events:
        actions
    console.log rv
    rv
