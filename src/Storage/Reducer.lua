--!strict
-- Requires
local TypeDefs = require(script.Parent.TypeDefinitions)

local Reducer = {}
Reducer.__index = Reducer

function Reducer.new(handler: TypeDefs.handlerFunction): TypeDefs.reducer -- Reducer constructor -> Reducer
    local self = setmetatable({}, Reducer) :: any

    self.handler = handler

    return self
end

function Reducer:dispatch(state: TypeDefs.state, action: TypeDefs.action): TypeDefs.state -- Dispatch data to Reducer and get new state  -> State // (... as signature from handlerFunction (!))!
    return self.handler(state, action)
end

return Reducer