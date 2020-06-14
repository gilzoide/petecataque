local args = require 'pl.lapp' [[
Usage: nested2object [--tight] [<input>] [<output>]

Options:
  --tight                       Output without indentation
  <input> (default stdin)       Input file. If absent or '-', reads from stdin
  <output> (default stdout)     Output file. If absent or '-', writes to stdout
]]
if args.input == '-' then args.input = io.stdin end
if args.output == '-' then args.output = io.stdout end

local nested = require 'lib.nested'
local empty = require 'lib.empty'
local ObjectLibrary = require 'object_library'.new()
Director = empty

local tablex = require 'pl.tablex'
local pretty = require 'pl.pretty'
local List = require 'pl.List'
local template = require 'pl.template'

local obj = assert(nested.decode_file(args.input, nested.bool_number_filter, true))

local import_directives = List()
local event_listeners = List()
local other_code = List()

local function object_exists(name)
    return ObjectLibrary.builtin_objects[name] ~= nil or ObjectLibrary:load(name) ~= nil
end

local function read_event_listener(t, i)
    local listener = {}
    for i = i, #t do
        local v = t[i]
        if v == 'do' then
            assert(#listener > 0, "Event listener must have at least one specifier")
            local handler = assert(t[i + 1], "Expected event handler after 'do' keyword")
            handler = handler:match('^[ \t\r\f\v]*\n*(.+)')
            handler = handler:match('(.-)\n*[ \t\r\f\v]*$')
            listener.handler = handler
            return listener, i + 1
        end
        listener[#listener + 1] = v
    end
    return nil, "Expected 'do' keyword in event listener definition"
end

local table2call, stringify
function stringify(value)
    if type(value) == 'table' then
        if type(value[1]) == 'string' and object_exists(value[1]) then
            return table2call(value)
        else
            return pretty.write(value, '')
        end
    else
        return string.format('%q', value)
    end
end
function table2call(value)
    local ttype = type(value[1])
    if ttype == 'string' then
        local name = value[1]
        local params = tablex.sub(value, 2)
        local kv = List()
        for k, v in nested.metadata(value) do
            kv:append(k .. ' = ' .. stringify(v))
        end
        if #kv > 0 then params[#params + 1] = '{' .. kv:concat(', ') .. '}' end
        return name .. '(' .. table.concat(params, ', ') .. ')'
    elseif ttype == 'table' then
        return table.concat(tablex.map(table2call, t))
    end
end

local i = 1
while i <= #obj do
    local v = obj[i]
    if v == 'on' then
        local listener
        listener, i = assert(read_event_listener(obj, i + 1))
        event_listeners:append(listener)
    elseif v == 'import' then
        local imported_name = obj[i + 1]
        assert(object_exists(imported_name), string.format("Expected Object name for import, found %q", imported_name))
        import_directives:append(imported_name)
        i = i + 1
    else
        other_code:append(table2call(v))
    end
    i = i + 1
end

local rendered = assert(template.substitute([[
-- Code generated by nested2object
# for k, v in nested.metadata(obj) do
$(k) = $(k) or $(stringify(v))
# end
# for imported_name in import_directives:iter() do
$(imported_name)(self)
# end
# for code in other_code:iter() do
$(code)
# end

# for listener in event_listeners:iter() do
#     local name = listener[1]
#     local args = name == 'update' and 'dt' or '...'
function $(name)($(args))
$(listener.handler)
end

# end
# for listener in event_listeners:iter() do
#     local name = listener[1]
#     if name ~= 'draw' and name ~= 'update' then
EventManager:register(self, $(stringify(name)))
#     end
# end
]], {
    event_listeners = event_listeners,
    import_directives = import_directives,
    nested = nested,
    obj = obj,
    other_code = other_code,
    stringify = stringify,
}))
local output = io.output(args.output)
output:write(rendered)
output:close()