simpleDumbHandler = {
  leftClick: (cobject, sendAction) ->
    sendAction {action: 'ACTIVATE'}

  rightClick: (cobject, sendAction) ->
    # just dump cobject info
    alert JSON.stringify cobject
}

App.actionHandlers = {}
App.actionHandlers['CDoor'] = simpleDumbHandler
App.actionHandlers['CDoorSwitch'] = simpleDumbHandler
