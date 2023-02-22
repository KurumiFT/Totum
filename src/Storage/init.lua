--!strict
-- Storage module
local TypeDefs = require(script.TypeDefinitions)
local Reducer = require(script.Reducer)
local Emitter = require(script.Parent.Emitter)
local EmitterTypeDefs = require(script.Parent.Emitter.TypeDefinitions)

local Storage = {}
Storage.__index = Storage
Storage.Reducer = Reducer

local UpdateEvent_Name = 'update' -- Name of update event for Emitter

function Storage.new(reducer: TypeDefs.reducer | TypeDefs.handlerFunction, initialState: TypeDefs.state): TypeDefs.storage -- Constructor for Storage object -> Storage
    local self = setmetatable({}, Storage) :: any

    self.state = initialState -- Initial state
    self.reducer = if typeof(reducer) == 'table' then reducer else Reducer.new(reducer) -- If reducer as handlerFunction -> create new Reducer with this handler
    self.emitter = Emitter.new()

    return self
end

function Storage:getState(): TypeDefs.state -- Get state from Storage -> State (Copy)
    return table.clone(self.state) -- Return copy of state table to prevert editing
end

function Storage:subscribe(callback: TypeDefs.emptyFunction): TypeDefs.emptyFunction -- Subscribe callback on change state -> Function to unsubscribe
    local event: EmitterTypeDefs.event = self.emitter:on(UpdateEvent_Name, function() -- Bind callback to event emitter
        callback() 
    end)

    return function() -- Unsubscribe function
         self.emitter:off(UpdateEvent_Name, event)
    end
end

function Storage:dispatch(action: TypeDefs.action)
    local new_state = self.reducer:dispatch(self.state, action)
    if not new_state then return end -- if reducer doesn't return value -> exit from function
    
    self.state = new_state -- Update state
    self.emitter:emit(UpdateEvent_Name)
end

return Storage