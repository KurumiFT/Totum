--!strict
-- Requires
local Event = require(script.Event) 
local TypeDefs = require(script.TypeDefinitions)

local Emitter = {}
Emitter.__index = Emitter

function Emitter.new(name: string?) -- Constructor for emitter -> Emitter
    local self = setmetatable({}, Emitter)
    
    self.events = {} -- Stored events

    return self
end

local function subTable(table: {}, key: string): {} -- Create subtable if there isn't
    if not table[key] then -- Check if doesn't exist
        table[key] = {} -- Create empty table on key
    end

    return table[key] -- Return subtable
end

function Emitter:on(name: string, callback: TypeDefs.callbackParams): TypeDefs.event -- Bind callback to emiiter -> Event
    local event: TypeDefs.event = Event.new(name, callback, false) -- Create new Event object

    table.insert(subTable(self.events, name), event) -- Store event into subtable
    return event
end

function Emitter:once(name: string, callback: TypeDefs.callbackParams): TypeDefs.event  -- Bind callback that can be emitted once -> Event
    local event: TypeDefs.event = Event.new(name, callback, true) -- Create new Event object where 'once' parameter is true

    table.insert(subTable(self.events, name), event) -- Store one-time event into subtable
    return event
end

function Emitter:emit(name: string, ...) -- Emit events that named with 'name' -> nil
    local subtable: {TypeDefs.event} = subTable(self.events, name) -- Get subtable of event's name
    local spent_events: {TypeDefs.event} = {} -- Queue of events to pop from subtable
    for _, event: TypeDefs.event in ipairs(subtable) do 
        if not event.available then warn("You called :off for Event directly...\nDon't do this, please"); table.insert(spent_events, event) -- Goes on pop queue
        else 
            event:emit(...) -- Emit event with given args
            if not event.available then -- If it was one-time event then it goes pop
                table.insert(spent_events, event) -- Insert into queue
            end
        end
    end

    -- Pop spents events
    for _, event: TypeDefs.event in ipairs(spent_events) do
        table.remove(subtable, table.find(subtable, event)) -- Remove event from subtable
    end
end

function Emitter:events(...: string): {TypeDefs.event} | {[string]:{TypeDefs.event}} -- Get all events that meet the requirements -> table of events
    if ... then -- If given requiremements
        local output_table: {TypeDefs.event} = {}

        for _, name : string in ipairs({...}) do -- Iter on every given name
            for _, event : TypeDefs.event in ipairs(subTable(self.events, name)) do -- Iter on subtable
                table.insert(output_table, event) -- Insert into output_table
            end
        end

        return output_table -- Return selected events
    else 
        return self.events -- Return all events in emitter
    end
end

function Emitter:off(name: string, event: TypeDefs.event): boolean -- Disable event by name and listener object -> boolean (success or not)
    local subtable: {TypeDefs.event} = subTable(self.events, name) -- Get subtable
    local index: number? = table.find(subtable, event) -- Get index of
    if not index then return false end -- if event doesn't exist in subtable, exit from this function
    event:off() -- Off event
    table.remove(subtable, index) -- Pop from table
    return true
end

function Emitter:offAll(name: string) -- Disable all events by name
    local subtable: {TypeDefs.event} = subTable(self.events, name) -- Get subtable of events
    for _, event: TypeDefs.event in ipairs(subtable) do -- For-each event in subtable
        event:off() -- Off event
        event = nil -- Set Event object to nil
    end
    self.events[name] = nil -- Clear prev storage
end

return Emitter