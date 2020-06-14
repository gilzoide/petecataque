local nested = require 'lib.nested'

local State = {}
State.__index = State

local ADD = 'ADD'
local CHANGE = 'CHANGE'
local REMOVE = 'REMOVE'
local SELF = 0

function State.new()
    return setmetatable({
        diff = { n = 0 },
    }, State)
end

function State:add(key, value)
    self:append_diff(ADD, key, value)
end

function State:add_toplevel(value)
    self:append_diff(ADD, SELF, value)
end

function State:change(key, value)
    self:append_diff(CHANGE, key, value)
end

function State:remove(key)
    self:append_diff(REMOVE, key, value)
end

function State:append_diff(...)
    self.diff.n = self.diff.n + 1
    self.diff[self.diff.n] = { ... }
end

function State:apply_add(key, value)
    if key == SELF then
        self[#self + 1] = value
    elseif type(key) == 'table' then
    else
    end
end

function State:apply()
    for i = 1, self.diff.n do
        local diff = self.diff[i]
        local op, key, value = diff[1], diff[2], diff[3]
        if op == ADD then
            self:apply_add(key, value)
        elseif op == CHANGE then
        elseif op == REMOVE then
        else error('FIXME!!!')
        end
    end

    self.diff.n = 0
end

return State