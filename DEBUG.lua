local DEBUG = {}

DEBUG.enabled = true

function DEBUG.STARTTIMER(name)
    DEBUG[name] = love.timer.getTime()
end

function DEBUG.REPORTTIMER(name)
    print('DEBUG.REPORTTIMER', name, love.timer.getTime() - DEBUG[name])
end

local function stringify_file(o)
    local file, line = o.__file, o.__line
    if file then
        return table.concat({ file, line }, ':')
    else
        return ""
    end
end

local function stringify_call(c)
    local recipe, name = unpack(c)
    local where = stringify_file(recipe)
    where = where and " @ " .. where or ""
    return string.format('\t%s.%s%s', recipe[1], name, where)
end

function DEBUG.PUSH_CALL(recipe, name)
    table.insert(DEBUG, { recipe, name })
end

function DEBUG.POP_CALL(recipe, name)
    local t = table.remove(DEBUG)
    assertf(t and t[1] == recipe and t[2] == name, "FIXME @ %s", stringify_call(t))
end

function love.errorhandler(msg)
    print(msg)
    print('recipe traceback:')
    for i = #DEBUG, 1, -1 do
        print(stringify_call(DEBUG[i]))
    end
    print(debug.traceback())
end

return DEBUG