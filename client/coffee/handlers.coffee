simpleDumbHandler = {
  leftClick: (cobject, sendAction) ->
    sendAction {action: 'ACTIVATE'}

  rightClick: (cobject, sendAction) ->
    # just dump cobject info
    alert JSON.stringify cobject
}

# CExampleBox impl
exampleBoxHandler = {
  leftClick: (cobject, sendAction) ->
    if cobject.clickedFiveTimes
      alert 'Woah, you\'re clicking a lot!  Take it easy.  RSI can be a bitch.'
    sendAction {action: 'ACTIVATE'}
}

App.actionHandlers = {}
App.actionHandlers['CDoor'] = simpleDumbHandler
App.actionHandlers['CDoorSwitch'] = simpleDumbHandler
App.actionHandlers['CExampleBox'] = exampleBoxHandler
