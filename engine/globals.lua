unpack = unpack or table.unpack
function rawpairs(t)
    return next, t, nil
end
function pairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__pairs or rawpairs)(t)
end
function default_object_pairs(self)
    return coroutine.wrap(function()
        for k, v in rawpairs(self) do
            if type(k) == 'string' then
                if k:startswith('__') then
                    k = nil
                elseif k:startswith('_') then
                    k = k:sub(2)
                end
            end
            if k then coroutine.yield(k, v) end
        end
    end)
end
nested = require 'nested'
nested_function = require 'nested.function'
nested_ordered = require 'nested.ordered'
nested_match = require 'nested.match'
wildcard_pattern = require 'wildcard_pattern'

do
    local gitignore = io.open(".gitignore")
    ignore_patterns = gitignore and wildcard_pattern.aggregate.from(gitignore) or wildcard_pattern.aggregate.new()
    ignore_patterns:extend(".*")
    if gitignore then gitignore:close() end
end

function assertf(cond, fmt, ...)
    return assert(cond, string.format(fmt, ...))
end

function errorf(fmt, ...)
    return error(string.format(fmt, ...))
end

Expression = require 'expression'
Object = require 'object'
Recipe = require 'recipe'
_ENV = _ENV or getfenv()

TIME = 0

get = nested.get
get_or_create = nested.get_or_create
set = nested.set
set_or_create = nested.set_or_create

function index_first_of(index, ...)
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t then
            local value = t[index]
            if value ~= nil then return value end
        end
    end
    return nil
end
function rawindex_first_of(index, ...)
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t then
            local value = rawget(t, index)
            if value ~= nil then return value end
        end
    end
    return nil
end
function create_index_first_of(index_chain)
    return index_chain and function(t, index)
        return index_first_of(index, unpack(index_chain))
    end
end

function safeunpack(v, i, j)
    if type(v) == 'table' then
        return unpack(v, i, j)
    elseif v ~= nil then
        return v
    end
    -- if v == nil, don't return any values
end
function safepack(...)
    if select('#', ...) > 1 then
        return {...}
    else
        return ...
    end
end

function string.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end
function string.endswith(s, suffix)
    return s:sub(- #suffix) == suffix
end

table.clear = table.clear or function(t)
    for k, v in rawpairs(t) do
        t[k] = nil
    end
end

function table_iextend(t, other)
    if other then
        local n = #t
        for i, v in ipairs(other) do
            t[n + i] = v
        end
    end
    return t
end

function index_or_create(t, index)
    local value = t[index]
    if value == nil then
        value = {}
        t[index] = value
    end
    return value
end

function addtoscene(obj)
    Scene:add(obj)
end

function clamp(x, min, max)
    if x < min then return min
    elseif x > max then return max
    else return x
    end
end

function deg2rad(angle)
    return angle * math.pi / 180
end
function rad2deg(angle)
    return angle * 180 / math.pi
end

function shallowcopy(value)
    if type(value) == 'table' then
        local newvalue = {}
        for k, v in pairs(value) do
            newvalue[k] = v
        end
        return newvalue
    else
        return value
    end
end
function deepcopy(value)
    if type(value) == 'table' then
        local newvalue = {}
        for k, v in pairs(value) do
            newvalue[k] = deepcopy(v)
        end
        return newvalue
    else
        return value
    end
end

function iter_chain(...)
    local n = select('#', ...)
    local chain = {...}
    return coroutine.wrap(function()
        for i = 1, n do
            local t = chain[i]
            if t then
                for k, v in pairs(t) do coroutine.yield(k, v) end
            end
        end
    end)
end

local function iter_dir(dir, info, ignore)
    local prefix = dir ~= '' and dir .. '/' or dir
    for i, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local path = prefix .. item
        if not (ignore and ignore(path)) then
            love.filesystem.getInfo(path, info)
            if info.type == 'directory' then
                iter_dir(path, info, ignore)
            elseif info.type == 'file' then
                coroutine.yield(item, path)
            end
        end
    end
end
function iter_file_tree(dir, ignore)
    return coroutine.wrap(function() return iter_dir(dir, {}, ignore) end)
end

function print_nested(...)
    local t = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        t[i] = nested.encode(v)
    end
    DEBUG.LOG(unpack(t))
    DEBUG.LOG()
end

function iscallable(v)
    if type(v) == 'function' then
        return true
    else
        local mt = getmetatable(v)
        return mt and mt.__call
    end
end

do
    local table_stack = require 'table_stack'
    ColorStack = table_stack.new()
    function ColorStack:push(color)
        if color then
            table_stack.push(self, love.graphics.getColor())
            love.graphics.setColor(color)
            return true
        else
            return false
        end
    end
    function ColorStack:pop()
        love.graphics.setColor(table_stack.pop(self))
    end
end

Input = require 'input'

Scene = require 'scene'.new()
InvokeQueue = require 'invoke_queue'.new()
Director = require 'director'
Resources = require 'resources'.new()
R = Resources

DEBUG.ONLY(function()
    function dump_state()
        local s = nested.encode(Scene) .. '\n\n' .. nested.encode(DEBUG.scene)
        DEBUG.LOG(s, '\n')
        love.system.setClipboardText(s)
    end
end)

function set_after_frames(n, ...)
    InvokeQueue:queue_after(n, set, ...)
end
function set_next_frame(...)
    set_after_frames(1, ...)
end
