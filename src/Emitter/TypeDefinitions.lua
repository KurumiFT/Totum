--!strict
export type callbackParams = (string, any) -> nil -- function for callback type
export type event = typeof(setmetatable({},{})) & { -- type of event 
    name: string,
    available: boolean,
    once: boolean,
    callback: callbackParams,
    off: (self: event) -> nil,
    emit: (self: event) -> nil
}

return {}