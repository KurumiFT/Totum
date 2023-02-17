--!strict
-- Require
local TypeDefs = require(script.Parent.TypeDefinitions)

local Event = {}
Event.__index = Event

function Event.new(name: string, callback: TypeDefs.callbackParams, once: boolean): TypeDefs.event -- Constructor for Event -> Event
    local self = setmetatable({}, Event) :: any

    self.name = name -- Name of Event,it may be needed
    self.available = true -- If Event is available for emit
    self.once = once -- Flag if Event can emit only once
    self.callback = callback -- Callback function

    return self
end

function Event:emit(...) -- Emit event's callback -> nil
    if not self.available then warn("You can't emit this Event!\nThis isn't available."); return end

    local args = {...} -- Pack vargs to prevert errors from IDE

    task.spawn(function() -- Fire callback async
        self.callback(self.name, unpack(args)) 
    end)

    if self.once then -- If this event can emit only once -> Set available to false
        self.available = false
    end
end

function Event:off() -- Off Event, please call this from Emitter, not directly -> nil
    self.available = false
end

return Event