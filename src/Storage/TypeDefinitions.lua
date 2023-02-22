--!strict

export type storage = typeof(setmetatable({},{})) & { -- type of event 
    state: state,
    reducer: reducer,
    getState: (self: storage) -> state,
    dispatch: (self: storage, action) -> nil,
    subscribe: (self: storage, emptyFunction) -> emptyFunction
}

export type action = { -- action for handler function signature
    type: string,
    [string]: any
}

export type emptyFunction = ()->nil

export type state = typeof(table) -- type of state object

export type handlerFunction = (state, action) -> state -- type of handler function for reducer

export type reducer = typeof(setmetatable({}, {})) & { -- reducer type
    handler: handlerFunction,
    dispatch: (self: reducer, state, action) -> state
}

return {}